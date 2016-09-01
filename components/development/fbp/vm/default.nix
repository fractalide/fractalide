{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , path
  , option_path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph path option_path ];
  depsSha256 = "15pc3jjb143kqb5rvjibzlaal8b5zr625rcp91nbdq0wcjch7x3r";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
