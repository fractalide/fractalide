{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file_list" "path" ];
  depsSha256 = "1svkpcqy9hkh4v53qyd3h172svl69kxxs8d29jkfpnx3x39q33dh";

  meta = with stdenv.lib; {
    description = "Component: List files in a folder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/fs/dir/list;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
