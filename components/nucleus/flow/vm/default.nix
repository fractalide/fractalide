{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , path
  , option_path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph path option_path ];
  depsSha256 = "084q9azhgqqa6bbjndmhgavbkb6jdbqbzq29qcq482vcyb9q1xw9";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
