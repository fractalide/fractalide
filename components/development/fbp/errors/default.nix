{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["fbp_graph" "fbp_semantic_error" "file_error"];
  depsSha256 = "01fngq0qlwz8w2h44ha64xhjk9p8n0bjrfqbmm3908vgj0qq76wy";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/fvm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
