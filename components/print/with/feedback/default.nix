{ stdenv, buildFractalideComponent, genName, upkeepers
  , path
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ path value_string ];
  depsSha256 = "1jhdmqyvgllmxha2ir1xhk33fc8phslp867d56v3ghgpl7w88b80";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
