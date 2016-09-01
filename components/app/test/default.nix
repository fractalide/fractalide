{ stdenv, buildFractalideSubnet, upkeepers
  , debug
  , ip_delay
  , ip_action
  , ui_js_page
  , ui_js_tag
  , ui_js_block
  , ui_js_flex
  , ui_js_placeholder
  , ui_js_edit
  # contracts 
  , js_create
  , generic_text
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td(${ui_js_flex}) output -> input page(${ui_js_page})

   '${generic_text}:(text="initial")~create' -> input edit(${ui_js_edit}) output -> places[1] td()

   '${js_create}:(type="span", text="hello")~create' -> input t(${ui_js_tag}) output -> places[2] td()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
