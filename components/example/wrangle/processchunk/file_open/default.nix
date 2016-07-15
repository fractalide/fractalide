{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["value_string" "path" "file_error"];
  depsSha256 = "0xdxdj8051vvi8zbg37qwvf3gsydr72siqfimx2sid1bbqckhxg2";

  meta = with stdenv.lib; {
    description = "Component: input: a path, output: a list of filenames";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/open;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
