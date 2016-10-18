{ stdenv, buildFractalideComponent, genName, upkeepers
  , quadruple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ quadruple ];
  depsSha256 = "1birx0k70wgqib9palwzds8f0pqh9kb39szmnipzx21lzhlcl8zx";

  meta = with stdenv.lib; {
    description = "Component: Print raw unanonymized and anonymized statistics to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
