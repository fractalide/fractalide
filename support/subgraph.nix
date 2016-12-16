{ stdenv, genName, writeTextFile}:
{ src, flowscript, name ? null, ... } @ args:
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
    #echo "SUBGRAPH"
    mkdir -p $out/lib
    cp  ${subgraph-txt} $out/lib/lib.subgraph
    '';
  })
