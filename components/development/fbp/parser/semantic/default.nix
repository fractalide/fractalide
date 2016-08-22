{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_semantic_error
  , fbp_graph
  , fbp_lexical
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_semantic_error fbp_graph fbp_lexical ];
  depsSha256 = "0z6bkvaa5zrjxiwql3wl1whlf4y6mddmw2wjygqqp7mrvwfx2669";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming semantics";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/semantic;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
