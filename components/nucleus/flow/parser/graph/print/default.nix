{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph ];
  depsSha256 = "1lcaa74xvrqh43v45badvygakp3zb0h8likfsad54lhjqba48njs";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming graph printer";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/print_graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
