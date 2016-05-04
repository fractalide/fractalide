{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file_desc"];
  depsSha256 = "183iqinczh4w8h4s1g2g53kl7igybmrf4x8s16s37kkaw56b67hn";

  meta = with stdenv.lib; {
    description = "Component: Prints the contents of a file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
