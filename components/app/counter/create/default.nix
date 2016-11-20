{ stdenv, buildFractalideComponent, genName, upkeepers
  , app_counter
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts =  [ app_counter js_create];
  depsSha256 = "0yav2znjhqlqh6f17jn8sjdk7sf7wxjm5y6df8nxmgiv14x5ln1f";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod text";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
