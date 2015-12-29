{ stdenv, writeTextFile}:
{ name, text ? null, ... } @ args:
let
contract = writeTextFile {
  name = name;
  text = builtins.readFile text;
  executable = false;
};
in
stdenv.mkDerivation (args // {
  name = name;
  unpackPhase = "true";
  installPhase = ''
  mkdir -p $out/src
  cp ${contract} $out/src/contract.capnp'';
})
