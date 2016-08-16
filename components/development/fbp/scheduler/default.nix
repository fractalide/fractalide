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
  depsSha256 = "0avhvc2b64f9hcsv62sl99wv5ssj4f7xavgc5kkx11xmmx7sm2fv";

  meta = with stdenv.lib; {
    description = "Component: Fractalide scheduler";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
