{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text ];
  depsSha256 = "0rf7fwp1x5n36zg53kq9flm8akf27hp2hizydzz6f7bwxvjprplp";

  meta = with stdenv.lib; {
    description = "Component: Print to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/io/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
