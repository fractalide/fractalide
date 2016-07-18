{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file_list" "path" "value_string"];
  depsSha256 = "1csgdw9h69g8fw9p7k1ig2p95l8bsjliknv4zddzi37syr20ghps";

  meta = with stdenv.lib; {
    description = "Component: Iterate over a list of 1000 file paths";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangler/iterate_paths;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
