{ stdenv, buildFractalideComponent, genName, upkeepers
  , app_counter
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts =  [ app_counter js_create];
  depsSha256 = "0llwv8pxsv0mfgzapwc1jzrg9llydnfg8h40l88dmzh5f8pbfcr5";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod text";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
