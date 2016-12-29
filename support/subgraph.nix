{ stdenv, genName, writeTextFile}:
{ src, flowscript, edges ? [], name ? null, ... } @ args:
  let
  subgraph-name = if name == null then genName src else name;
  subgraph-txt = writeTextFile {
    name = subgraph-name;
    text = flowscript;
    executable = false;
  };
  in stdenv.mkCachedDerivation  (args // {
    name = subgraph-name;
    unpackPhase = "true";
    installPhase = ''
    runHook preInstall
    propagated=""
    for i in $edges; do
      findInputs $i propagated propagated-build-inputs
    done
    propagated1=""
    for i in $propagated; do
      propagated1="$propagated1 $i/src/edge_capnp.rs"
    done
    touch edge_capnp.rs
    for i in $propagated1; do
      cat $i >> edge_capnp.rs
    done
    mkdir -p $out/lib
    cp  ${subgraph-txt} $out/lib/lib.subgraph
    cp edge_capnp.rs $out/lib/edge_capnp.rs
    '';
  })
