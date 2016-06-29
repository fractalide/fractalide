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

in stdenv.mkCachedDerivation  (args // {
  name = name;
  unpackPhase = "true";
  installPhase = ''
  runHook preInstall
  mkdir -p $out/src
  cp ${contractText} $out/src/contract.capnp
  echo "CONTRACT"
  ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/contract.capnp
  '';
})


