{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph ];
  depsSha256 = "13xlhgca49896354mk1lawjk6ywai3jwvqgkpsnd0miybmf600bd";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming graph printer";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/print_graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
