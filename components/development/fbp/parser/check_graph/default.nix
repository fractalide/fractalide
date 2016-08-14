{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , fbp_semantic_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph fbp_semantic_error ];
  depsSha256 = "1nb481fxv0j0j15j5cn97kv7vf7892kbgb935wmc9h3mdnv7m9r8";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming graph checker";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/print_graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
