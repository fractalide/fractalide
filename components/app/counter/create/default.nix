{ stdenv, buildFractalideComponent, genName, upkeepers
  , app_counter
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts =  [ app_counter js_create];
  depsSha256 = "0j64y4da9ings4a2zj472wxsdzjvi6d0bzccg95d325b7z6p16j8";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod text";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
