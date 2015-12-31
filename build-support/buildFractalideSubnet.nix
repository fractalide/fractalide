{ stdenv, writeTextFile #, fvm
  }:
{ name, text ? null, ... } @ args:
let
subnet = writeTextFile {
  name = name;
  text = builtins.readFile text;
  executable = false;
};
in
stdenv.mkDerivation (args // {
  name = name;
  unpackPhase = "true";
  installPhase = ''
  mkdir -p $out/lib
  cp ${subnet} $out/lib/lib.subnet'';
  #checkPhase = "fvm test $out/lib/lib.subnet";
})
