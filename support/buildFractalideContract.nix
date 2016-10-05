{ stdenv, writeTextFile, capnproto, capnpc-rust, genName }:
{ src, contract, ... } @ args:

let
name = genName src;
contractText = writeTextFile {
  name = name;
  text = contract;
  executable = false;
};

in stdenv.mkCachedDerivation  (args // {
  name = name;
  unpackPhase = "true";
  installPhase = ''
  runHook preInstall
  mkdir -p $out/src
  cp ${contractText} $out/src/contract.capnp
  ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/contract.capnp -I "/"
  '';
})
