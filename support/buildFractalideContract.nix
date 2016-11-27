{ stdenv, writeTextFile, capnproto, capnpc-rust, genName }:
{ src, schema, importedContracts ? [], ... } @ args:

let
name = genName src;
contractText = writeTextFile {
  name = name;
  text = schema;
  executable = false;
};

in stdenv.mkCachedDerivation  (args // {
  name = name;
  unpackPhase = "true";
  propagatedBuildInputs = importedContracts;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/src
    mkdir -p $out/nix-support
    for i in $importedContracts; do
      echo $i >> $out/nix-support/propagated-build-inputs
    done
    cp ${contractText} $out/src/contract.capnp
    ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/contract.capnp --src-prefix $out/src/ -I "/"
  '';
})
