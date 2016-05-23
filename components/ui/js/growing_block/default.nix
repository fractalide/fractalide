{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ui_js_block
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create" "js_block" "generic_text" "fbp_action"];
  depsSha256 = "01062z2pzhd1jm5vag6nw17cdjk78163jq62b91c9cg6cj4sx6bk";
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
