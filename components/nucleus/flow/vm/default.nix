{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , path
  , option_path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph path option_path ];
  depsSha256 = "0cscw4n3a6gfhxzn63r6q3yw9fyvb3gpz1i6bcvshy4rp4fp4bmz";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
