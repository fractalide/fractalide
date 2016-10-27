{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , path
  , generic_text
  , fbp_action
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph path generic_text fbp_action ];
  depsSha256 = "1zg4xqngg3blvscz0zp77j5xgp42ppxavwflcgxfrk5v8p1pzscs";

  meta = with stdenv.lib; {
    description = "Component: Fractalide scheduler";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
