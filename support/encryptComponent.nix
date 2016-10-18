{ pkgs, fetchFromGitHub, writeTextFile, buildGoPackage, debug }:
{ encrypt_for_keybase_user, using_my_keybase_config_file }:
component:
let
config_file = writeTextFile {
  name = "keybase_config_file";
  text = builtins.readFile using_my_keybase_config_file;
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
  name = oldAttrs.name + "-" + encrypt_for_keybase_user;
  impureEnvVars = ["http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    for f in $(find target/${directory} -maxdepth 1 -type f); do
    cp $f $out/lib
    done;
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


  /*$keybase \
  --socket-file=.keybase.pid \
  --log-file=./keybase.log \
  --config-file=${config_file} \
  encrypt ${encrypt_for_keybase_user} -i target/${directory}/libcomponent.so -b -o $out/lib/libcomponent.so.encrypted
  ls -la $out/lib/*/
