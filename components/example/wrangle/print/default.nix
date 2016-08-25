{ stdenv, buildFractalideComponent, genName, upkeepers
  , quadruple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ quadruple ];
  depsSha256 = "0180kzcks62jlzfak5k26svb29wn3xj1wc2bfgihkk61aya0829a";

  meta = with stdenv.lib; {
    description = "Component: Print raw unanonymized and anonymized statistics to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
