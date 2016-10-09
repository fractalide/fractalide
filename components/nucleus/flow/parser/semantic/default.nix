{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_semantic_error
  , fbp_graph
  , fbp_lexical
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_semantic_error fbp_graph fbp_lexical ];
  depsSha256 = "0bbinkwfjwbvl3jjx9ykshr0a39cjzymxkl00wz9zbzq0bq6aybl";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming semantics";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/semantic;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
