{ stdenv, genName, unifySchema, writeTextFile}:
{ src, flowscript, edges ? [],  name ? null, ... } @ args:
  let
  subgraph-name = if name == null then genName src else name;
  subgraph-txt = writeTextFile {
    name = subgraph-name;
    text = flowscript;
    executable = false;
  };
  unifiedSchema = unifySchema {
    name = subgraph-name;
    edges = edges;
    target = "capnp";
  };
  in stdenv.mkDerivation  (args // {
    name = subgraph-name;
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/lib
      ln -s ${unifiedSchema}/edge.capnp $out/lib/edge.capnp
      cp ${subgraph-txt} $out/lib/lib.subgraph
    '';
  })
