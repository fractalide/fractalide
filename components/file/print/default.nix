{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = filterContracts ["file"];
  depsSha256 = "1nfllagp9cgmk0gr6g47iqrbvm7cs3d81482krgj0la8m5p7lgci";

  meta = with stdenv.lib; {
    description = "Component: Prints the contents of a file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
