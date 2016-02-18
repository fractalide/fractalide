{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file"];
  depsSha256 = "0vjigcl0091slb53vaciswqikrx5wn7cr5r2xrrai1r23hg59ia9";

  meta = with stdenv.lib; {
    description = "Component: Prints the contents of a file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/file/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
