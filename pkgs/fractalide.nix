{ pkgs ? import <nixpkgs> {}
, stdenv ? pkgs.stdenv
, lib ? stdenv.lib
, fetchurl ? pkgs.fetchurl
, fetchgit ? pkgs.fetchgit
, racket ? pkgs.racket-minimal
, racket-lib ? racket // { env = racket.out; }
, unzip ? pkgs.unzip
, bash ? pkgs.bash
, racketIndexPatch ? builtins.toFile "racket-index.patch" ''
    diff --git a/pkgs/racket-index/setup/scribble.rkt b/pkgs/racket-index/setup/scribble.rkt
    index c79af9bf85..e4a1cf93e3 100644
    --- a/pkgs/racket-index/setup/scribble.rkt
    +++ b/pkgs/racket-index/setup/scribble.rkt
    @@ -874,6 +874,7 @@
             [(not latex-dest) (build-path (doc-dest-dir doc) file)]))
 
     (define (find-doc-db-path latex-dest user? main-doc-exists?)
    +  (set! main-doc-exists? #t)
       (cond
        [latex-dest
         (build-path latex-dest "docindex.sqlite")]
  ''
}:

let
extractPath = lib.makeOverridable ({ path, src }: stdenv.mkDerivation {
  inherit path src;
  name = builtins.elemAt (builtins.match "(|.*/)([^/]*)" path) 1;
  phases = "unpackPhase installPhase";
  installPhase = ''
    cp -a "${path}" $out
  '';
});

mkRacketDerivation = suppliedAttrs: let racketDerivation = lib.makeOverridable (attrs: stdenv.mkDerivation (rec {
  buildInputs = [ unzip racket attrs.racketBuildInputs ];
  circularBuildInputsStr = lib.concatStringsSep " " attrs.circularBuildInputs;
  racketBuildInputsStr = lib.concatStringsSep " " attrs.racketBuildInputs;
  racketConfigBuildInputs = builtins.filter (input: ! builtins.elem input attrs.reverseCircularBuildInputs) attrs.racketBuildInputs;
  racketConfigBuildInputsStr = lib.concatStringsSep " " (map (drv: drv.env) racketConfigBuildInputs);
  srcs = [ attrs.src ]
           ++ attrs.extraSrcs or (map (input: input.src) attrs.reverseCircularBuildInputs);
  inherit racket;
  outputs = [ "out" "env" ];

  phases = "unpackPhase patchPhase installPhase fixupPhase";
  unpackPhase = ''
    stripSuffix() {
      stripped=$1
      for suffix in .gz .tgz .zip .xz .tar; do
        stripped=''${stripped%$suffix}
      done
      echo $stripped
    }

    runHook preUnpack
    for unpackSrc in $srcs; do
      unpackName=$(stripSuffix $(stripHash $unpackSrc))
      mkdir $unpackName
      cd $unpackName
      unpackFile $unpackSrc
      cd -
      unpackedFiles=( $unpackName/* )
      if [ "''${unpackedFiles[*]}" = "$unpackName/$unpackName" ]; then
        mv $unpackName _
        chmod u+w _/$unpackName
        mv _/$unpackName $unpackName
        rmdir _
      fi
    done
    chmod u+w -R .
    find . -name '*.zo' -delete
    runHook postUnpack
  '';

  patchPhase = ''
    if [ -d racket-index ]; then
        ( cd racket-index && patch -p3 < ${racketIndexPatch} )
    fi
  '';

  racket-cmd = "${racket}/bin/racket -G $env/etc/racket -U -X $env/share/racket/collects";
  raco = "${racket-cmd} -N raco -l- raco";
  maxFileDescriptors = 3072;

  make-config-rktd = builtins.toFile "make-config-rktd.rkt" ''
    #lang racket

    (define (make-config-rktd out racket deps)
      (define out-deps-racket (append (list racket) (cons out deps)))
      (define (share/racket suffix)
        (for/list ((path out-deps-racket))
                  (format "~a/share/racket/~a" path suffix)))

      (define lib-dirs
        (append
          (for/list ((name (cons out deps)))
                    (format "~a/share/racket/lib" name))
          (list (format "~a/lib/racket" racket))))

      (define config-rktd
        `#hash(
          (share-dir . ,(format "~a/share/racket" out))
          (lib-search-dirs . ,lib-dirs)
          (lib-dir . ,(format "~a/lib/racket" out))
          (bin-dir . ,(format "~a/bin" out))
          (absolute-installation . #t)
          (installation-name . ".")

          (links-search-files . ,(share/racket "links.rktd"))
          (pkgs-search-dirs . ,(share/racket "pkgs"))
          (collects-search-dirs . ,(share/racket "collects"))
          (doc-search-dirs . ,(share/racket "doc"))
        ))
      (write config-rktd))

    (command-line
      #:program "make-config-rktd"
      #:args (out racket . deps)
             (make-config-rktd out racket deps))
  '';

  installPhase = ''
    runHook preInstall

    restore_pipefail=$(shopt -po pipefail)
    set -o pipefail

    if ! ulimit -n $maxFileDescriptors; then
      echo >&2 If the number of allowed file descriptors is lower than '~3072,'
      echo >&2 packages like drracket or racket-doc will not build correctly.
      echo >&2 If raising the soft limit fails '(like it just did)', you will
      echo >&2 have to raise the hard limit on your operating system.
      echo >&2 Examples:
      echo >&2 debian: https://unix.stackexchange.com/questions/127778
      echo >&2 MacOS: https://superuser.com/questions/117102
      exit 2
    fi

    mkdir -p $env/etc/racket $env/share/racket $out
    # Don't use racket-cmd as config.rktd doesn't exist yet.
    racket ${make-config-rktd} $env ${racket} ${racketConfigBuildInputsStr} > $env/etc/racket/config.rktd

    if [ -n "${circularBuildInputsStr}" ]; then
      echo >&2 WARNING: This derivation should not have been depended on.
      echo >&2 Any derivation depending on this one should have depended on one of these instead:
      echo >&2 "${circularBuildInputsStr}"
      exit 0
    fi

    echo ${racket-cmd}

    mkdir -p $env/share/racket/collects $env/lib $env/bin
    for bootstrap_collection in racket compiler syntax setup openssl ffi file pkg planet; do
      cp -rs $racket/share/racket/collects/$bootstrap_collection \
        $env/share/racket/collects/
    done
    cp -rs $racket/lib/racket $env/lib/racket
    find $env/share/racket/collects $env/lib/racket -type d -exec chmod 755 {} +

    printf > $env/bin/racket "#!${bash}/bin/bash\nexec ${racket-cmd} \"\$@\"\n"
    chmod 555 $env/bin/racket

    # install and link us
    install_names=""
    for install_info in ./*/info.rkt; do
      install_name=''${install_info%/info.rkt}
      if ${racket-cmd} -e "(require pkg/lib)
                           (define name \"''${install_name#./}\")
                           (for ((scope (get-all-pkg-scopes)))
                             (when (member name (installed-pkg-names #:scope scope))
                                   (eprintf \"WARNING: ~a already installed in ~a -- not installing~n\"
                                            name scope)
                                   (exit 1)))"; then
        install_names+=" $install_name"
      fi
    done

    if [ -n "$install_names" ]; then
      ${raco} pkg install --no-setup --copy --deps fail --fail-fast --scope installation $install_names |&
        sed -Ee '/warning: tool "(setup|pkg|link)" registered twice/d'

      setup_names=""
      for setup_name in $install_names; do
        setup_names+=" ''${setup_name#./}"
      done
      ${raco} setup --no-user --no-pkg-deps --fail-fast --only --pkgs $setup_names |&
        sed -ne '/updating info-domain/,$p'
    fi

    mkdir -p $out/bin
    for launcher in $env/bin/*; do
      if ! [ "''${launcher##*/}" = racket ]; then
        ln -s "$launcher" "$out/bin/''${launcher##*/}"
      fi
    done

    eval "$restore_pipefail"
    runHook postInstall

    find $env/share/racket/collects $env/lib/racket -lname "$racket/*" -delete
    find $env/share/racket/collects $env/lib/racket $env/bin -type d -empty -delete
  '';
} // attrs)) suppliedAttrs; in racketDerivation // { inherit racketDerivation; };

  _racket-lib = racket-lib;
  _base = mkRacketDerivation rec {
  name = "base";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _racket-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _typed-map-lib = mkRacketDerivation rec {
  name = "typed-map-lib";
  src = extractPath {
    path = "typed-map-lib";
    src = fetchgit {
    url = "git://github.com/jsmaniac/typed-map.git";
    rev = "c9c5a236f4e32d9391df3edffdf9b1a55401fe31";
    sha256 = "150agc51y1kvrarg0n6r2x6n3awnvivqj5k78gx9ngr8q31zl83f";
  };
  };
  racketBuildInputs = [ _base _typed-racket-lib _racket-lib _source-syntax _compatibility-lib _string-constants-lib _scheme-lib _net-lib _sandbox-lib _srfi-lite-lib _errortrace-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _typed-racket-lib = mkRacketDerivation rec {
  name = "typed-racket-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _base _source-syntax _compatibility-lib _string-constants-lib _racket-lib _scheme-lib _net-lib _sandbox-lib _srfi-lite-lib _errortrace-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _source-syntax = mkRacketDerivation rec {
  name = "source-syntax";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _base _racket-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _compatibility-lib = mkRacketDerivation rec {
  name = "compatibility-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _scheme-lib _base _net-lib _sandbox-lib _racket-lib _srfi-lite-lib _errortrace-lib _source-syntax ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _string-constants-lib = mkRacketDerivation rec {
  name = "string-constants-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _base _racket-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _scheme-lib = mkRacketDerivation rec {
  name = "scheme-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _base _racket-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _net-lib = mkRacketDerivation rec {
  name = "net-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _srfi-lite-lib _base _racket-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _sandbox-lib = mkRacketDerivation rec {
  name = "sandbox-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _scheme-lib _base _errortrace-lib _racket-lib _source-syntax ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _srfi-lite-lib = mkRacketDerivation rec {
  name = "srfi-lite-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _base _racket-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _errortrace-lib = mkRacketDerivation rec {
  name = "errortrace-lib";
  src = fetchurl {
    url = "http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip";
    sha1 = "9f098dddde7f217879070816090c1e8e74d49432";
  };
  racketBuildInputs = [ _base _source-syntax _racket-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
  _fractalide = mkRacketDerivation rec {
  name = "fractalide";
  src = ../../fractalide;
  racketBuildInputs = [ _base _typed-map-lib _racket-lib _typed-racket-lib _source-syntax _compatibility-lib _string-constants-lib _scheme-lib _net-lib _sandbox-lib _srfi-lite-lib _errortrace-lib ];
  circularBuildInputs = [  ];
  reverseCircularBuildInputs = [  ];
  };
in
_fractalide
