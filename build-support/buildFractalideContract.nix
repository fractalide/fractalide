{ stdenv, writeTextFile, capnproto, capnpc-rust, genName }:
{ src, ... } @ args:
let
name = genName src;
text = src + "/contract.capnp";
contractText = writeTextFile {
  name = name;
  text = builtins.readFile text;
  executable = false;
};

contract = stdenv.mkDerivation {
  name = name;
  unpackPhase = "true";
  installPhase = ''
  mkdir -p $out/src
  cp ${contractText} $out/src/contract.capnp
  ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/contract.capnp
  '';
  };

in
contract


