{ stdenv, genName, writeTextFile}:
{ src, flowscript, edges ? [],  name ? null, ... } @ args:
  let
  subgraph-name = if name == null then genName src else name;
  subgraph-txt = writeTextFile {
    name = subgraph-name;
    text = flowscript;
    executable = false;
  };
  in stdenv.mkDerivation  (args // {
    name = subgraph-name;
    installPhase = ''
      mkdir -p $out/lib
      cp ${subgraph-txt} $out/lib/lib.subgraph
    '';
  })
