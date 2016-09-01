{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , fbp_semantic_error
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph fbp_semantic_error file_error ];
  depsSha256 = "1rg3nz4yy10icw1jvhcn48qpbjpbb09ka4k4p8sn4y1f2mh57jf8";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
