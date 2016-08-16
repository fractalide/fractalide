{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_triple ];
  depsSha256 = "0xh5hkja33jl70m4rwhwrn6qwc2g54cgy0xv5xc83cm80mpq4g01";

  meta = with stdenv.lib; {
    description = "Component: Anonymize the data such that any triple that has a count of less than 6 is removed from the list";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/anonymize;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
