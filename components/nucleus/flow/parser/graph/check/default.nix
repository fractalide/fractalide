{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , fbp_semantic_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph fbp_semantic_error ];
  depsSha256 = "1v2g4vq3ys1wvkm7j7k687hhdwkzk4ayndl46lc0rw9krdkbwzls";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming graph checker";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/print_graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
