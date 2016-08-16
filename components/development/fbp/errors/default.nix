{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , fbp_semantic_error
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph fbp_semantic_error file_error ];
  depsSha256 = "1mwih37698za7lsj9hal8f0z0k0l37qsyxsyjbzy5r3riqsir0fl";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
