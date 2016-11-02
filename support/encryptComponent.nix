{ pkgs, fetchFromGitHub, writeTextFile, buildGoPackage, debug }:
{ fractalide_user, keybase_config_file }:
component:
let
config_file = writeTextFile {
  name = "keybase_config_file";
  text = builtins.readFile keybase_config_file;
  executable = false;
};
keybase = buildGoPackage rec {
  name = "keybase-${version}";
  version = "1.0.17";
  rev = "v${version}";
  goPackagePath = "github.com/keybase/client";
  subPackages = [ "go/keybase" ];
  dontRenameImports = true;
  src = fetchFromGitHub {
    owner = "keybase";
    repo = "client";
    inherit rev;
    sha256 = "14cj0npsvnc3whw7gashgd7lhj3lvjdkivsnvsjg7dp3hifvqxnx";
  };
  buildFlags = [ "-tags production" ];
};
directory = if debug == "true" then "debug" else "release";
fractalideComponent = pkgs.stdenv.lib.overrideDerivation component (oldAttrs : {
  name = oldAttrs.name + "-" + fractalide_user;
  impureEnvVars = ["http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    touch /tmp/keybase.pid
    exe="/bin/keybase"
    keybase=$(<${keybase}/nix-support/propagated-native-build-inputs)$exe

    $keybase \
    --socket-file=.keybase.pid \
    --log-file=./keybase.log \
    --config-file=${config_file} \
    encrypt ${fractalide_user} -i target/${directory}/libcomponent.so -b -o $out/lib/libcomponent.so.encrypted
    ls -la $out/lib/
    '' ;
  });
  in
  fractalideComponent
  /*runHook preInstall
  mkdir -p $out/lib
  touch /tmp/keybase.pid
  exe="/bin/keybase"
  keybase=$(<${keybase}/nix-support/propagated-native-build-inputs)$exe
  $keybase \
  --socket-file=/tmp/keybase.pid \
  --log-file=./keybase.log \
  --config-file=${config_file} \
  ping*/

  /*runHook preInstall
  mkdir -p $out/lib
  for f in $(find target/${directory} -maxdepth 1 -type f); do
  cp $f $out/lib
  done;*/
