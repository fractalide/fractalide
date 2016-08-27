{ stdenv, buildFractalideSubnet, upkeepers
  , ui_js_tag
  , ui_js_visible
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input div(${ui_js_tag}) output => output
   places => places orderer(${ui_js_visible}) output -> input div()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: editor card";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
