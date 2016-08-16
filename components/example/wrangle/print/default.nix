{ stdenv, buildFractalideComponent, genName, upkeepers
  , quadruple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ quadruple ];
  depsSha256 = "1vnn3rlq1pm1rpypdscw9w658v18swmdcdidy2hk8vfhsc5yqgwg";

  meta = with stdenv.lib; {
    description = "Component: Print raw unanonymized and anonymized statistics to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
