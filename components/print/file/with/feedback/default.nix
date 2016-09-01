{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string list_triple];
  depsSha256 = "0hxhlxwr58m6vhr32aqkcydg72pwvcxg5vmhw12shlyi6ds0pxa1";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
