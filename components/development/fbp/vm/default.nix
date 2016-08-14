{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , path
  , option_path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph path option_path ];
  depsSha256 = "136p5mzm4s0vrzh34m1vvx32piqisrp7yak83s2v2301p03an9mm";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
