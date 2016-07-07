{ stdenv, buildFractalideSubnet, upkeepers
  , debug
  , ip_delay
  , ip_action
  , ui_js_page
  , ui_js_tag
  , ui_js_block
  , ui_js_flex
  , ui_js_placeholder
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   'js_create:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td(${ui_js_flex}) output -> input page(${ui_js_page})

   'js_create:(type="span", text="hello SVG!", style=[(key="color", val="red")])~create' -> input text(${ui_js_tag}) output -> places[0] td()


   'js_create:(type="svg", attr=[(key="width", val="200"), (key="height", val="200")])~create' -> input block(${ui_js_block}) output -> places[1] td()

   'js_create:(type="circle", attr=[(key="r", val="70"), (key="fill", val="yellow")])~create' -> input tag(${ui_js_tag}) output -> places block()

   'js_create:(type="circle", attr=[(key="cx", val="100"), (key="r", val="70"), (key="fill", val="red")])~create' -> input tag2(${ui_js_tag}) output -> places block()


   'js_create:(type="div")~create' -> input ph(${ui_js_placeholder}) output -> places[2] td()

   'js_create:(type="span", text="hello Fractlide!", style=[(key="color", val="red")])~create' -> input t1(${ui_js_tag}) output -> places[0] ph()

   'js_create:(type="span", text="Changed!", style=[(key="color", val="blue")])~create' -> input t2(${ui_js_tag}) output -> places[1] ph()

   'generic_text:(text="i")~display' -> input t1()

   'generic_text:(text="i")~display' ->
       input d1(${ip_delay}) output ->
       input d2(${ip_delay}) output ->
       input d3(${ip_delay}) output ->
       input t2()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
