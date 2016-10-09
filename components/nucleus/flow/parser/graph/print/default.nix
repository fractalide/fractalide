{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph ];
  depsSha256 = "1p45qx1nsh1b329gpkk1wzh9p90x27c8qkblahfgj40js6wjbb31";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming graph printer";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/print_graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
