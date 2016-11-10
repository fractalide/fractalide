{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph ];
  depsSha256 = "0gz5v7iicv6ygc7k65079dcf0nvxpiqam1807wz26d1lpjdx26jn";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming graph printer";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/print_graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
