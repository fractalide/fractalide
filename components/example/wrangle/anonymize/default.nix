{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["list_triple"];
  depsSha256 = "1ymn21kh1ffm1jivpraswlrscibv8f0qxn8r3fyqgp8j3fydgvf1";

  meta = with stdenv.lib; {
    description = "Component: Anonymize the data such that any triple that has a count of less than 5 is removed from the list";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/anonymize;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
