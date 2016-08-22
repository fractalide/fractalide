{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_triple ];
  depsSha256 = "0dbydai58z6npf8ws0dqp7xcbi5b3gbsc31d2x9hs79cvc1yk275";

  meta = with stdenv.lib; {
    description = "Component: Anonymize the data such that any triple that has a count of less than 6 is removed from the list";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/anonymize;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
