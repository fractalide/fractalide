{ stdenv, writeTextFile, capnproto, capnpc-rust }:
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
  cp ${contract} $out/src/contract.capnp
  ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/contract.capnp
  '';
})
