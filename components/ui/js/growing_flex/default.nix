{ stdenv, buildFractalideComponent, genName, upkeepers
  , ui_js_flex
  , js_create
  , generic_text
  , fbp_action
  , ... }:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ js_create generic_text fbp_action ];
  depsSha256 = "00vm4bzyd59xfqhm66pmmaxml3lmgzkph7xgwyfc42ahcy4bal8k";
  configurePhase = ''
      substituteInPlace src/lib.rs --replace "ui_js_flex" "${ui_js_flex}"
  '';
  meta = with stdenv.lib; {
    description = "Component: draw a growable flex ";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
