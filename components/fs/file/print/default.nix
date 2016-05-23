{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file_desc"];
  depsSha256 = "0w54zsk08l83z4nih7hsvkw33qq0gm7cin5s4k23pypa1yjj21rh";

  meta = with stdenv.lib; {
    description = "Component: Prints the contents of a file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
