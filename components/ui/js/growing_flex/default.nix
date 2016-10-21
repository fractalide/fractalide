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
  depsSha256 = "1j12y2pqrw9nwaxh22k23fx2l6hc2ssm6pvbxhrbvjlh95i6fcc2";
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
