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
  depsSha256 = "1cc7am1z2w657m92vsqd2289gyqlkn3i6rq2y4nx8v2h61zif9yc";

  meta = with stdenv.lib; {
    description = "Component: Fractalide scheduler";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
