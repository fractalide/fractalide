{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ui_js_block
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create" "js_block" "generic_text" "fbp_action"];
  depsSha256 = "1ga35jg9jxmdh3v6j4vr8hlj8d9x9likl060nh6b4mxyhz02qrcj";
  configurePhase = ''
      substituteInPlace src/lib.rs --replace "ui_js_block" "${ui_js_block}"
  '';
  meta = with stdenv.lib; {
    description = "Component: draw a growable block ";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
