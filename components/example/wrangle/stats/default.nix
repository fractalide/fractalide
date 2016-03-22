{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["list_triple" "quadruple"];
  depsSha256 = "1zx0kbya736phg3j6gchsziayddjcazqya9lxqdjl9cl2l66z3r2";

  meta = with stdenv.lib; {
    description = "Component: Print average, mean, min and max to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/stats;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
