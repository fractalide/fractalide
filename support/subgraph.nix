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
    propagatedRs=""
    propagatedCapnp=""
    for i in $propagated; do
      propagatedRs="$propagatedRs $i/src/edge_capnp.rs"
      propagatedCapnp="$propagatedCapnp $i/src/edge.capnp"
    done
    touch edge_capnp.rs
    touch edge.capnp
    for i in $propagatedRs; do
      cat $i >> edge_capnp.rs
    done
    for i in $propagatedCapnp; do
      cat $i >> edge.capnp
    done
    mkdir -p $out/lib
    cp  ${subgraph-txt} $out/lib/lib.subgraph
    cp edge_capnp.rs $out/lib/edge_capnp.rs
    awk '/@0x/&&c++>0 {next} 1' edge.capnp > $out/lib/edge.capnp
    '';
  })
