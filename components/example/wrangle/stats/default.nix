{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["list_triple" "quadruple"];
  depsSha256 = "1hqv9py71ix6lc2sagphwj7kaflifvi5fl9azgk6i2zhk3jxmmvz";

  meta = with stdenv.lib; {
    description = "Component: Print average, mean, min and max to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/stats;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
