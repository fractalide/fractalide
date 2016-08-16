{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , path
  , option_path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph path option_path ];
  depsSha256 = "01s8hnjqrinbmgjyi9dzr46iwangbh3yfm6dl998gfd8wz2cia4w";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
