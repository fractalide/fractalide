{ stdenv, writeTextFile, capnproto, capnpc-rust, genName }:
{ src, schema, edges ? [], ... } @ args:

let
name = genName src;
edgeText = writeTextFile {
  name = name;
  text = schema;
  executable = false;
};

in stdenv.mkCachedDerivation (args // {
  name = name;
  unpackPhase = "true";
  propagatedBuildInputs = edges;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/src
    mkdir -p $out/nix-support
    for i in $edges; do
      echo $i >> $out/nix-support/propagated-build-inputs
    done
    cp ${edgeText} $out/src/edge.capnp
    ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/edge.capnp --src-prefix $out/src/ -I "/"
  '';
})
