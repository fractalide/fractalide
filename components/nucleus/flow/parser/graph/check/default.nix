{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , fbp_semantic_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph fbp_semantic_error ];
  depsSha256 = "0hf46fv6063m7ck3n41ibgnwxiy31qq8pb1ihli1xdc4kqrwky69";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming graph checker";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/print_graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
