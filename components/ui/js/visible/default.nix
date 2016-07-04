{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create"];
  depsSha256 = "1ga35jg9jxmdh3v6j4vr8hlj8d9x9likl060nh6b4mxyhz02qrcj";
  meta = with stdenv.lib; {
    description = "Component: draw a place holder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
