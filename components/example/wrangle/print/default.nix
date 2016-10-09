{ stdenv, buildFractalideComponent, genName, upkeepers
  , quadruple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ quadruple ];
  depsSha256 = "14i240z0piqv58356525mk1axwkb98d0crpllc7x6chsvjdljhmv";

  meta = with stdenv.lib; {
    description = "Component: Print raw unanonymized and anonymized statistics to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
