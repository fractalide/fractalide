{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_semantic_error
  , fbp_graph
  , fbp_lexical
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_semantic_error fbp_graph fbp_lexical ];
  depsSha256 = "1w7sx1wyp2kaa6i45m3k21s0s7j4ln6pacvk1qxqwa37spnzg3fv";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming semantics";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/semantic;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
