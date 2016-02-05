{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file"];
  depsSha256 = "1flqcsa0mqaql1sxaa9p5gfnlcg9kb8jap5h5h279320gklv8d2w";

  meta = with stdenv.lib; {
    description = "Component: Prints the contents of a file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
