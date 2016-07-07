{ stdenv, buildFractalideSubnet, upkeepers
  , debug
  , ip_action
  , ui_js_page
  , ui_js_tag
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   // 'js_create:(name="newdiv", type="div", attr=[(key="disabled", val="true")], append="main", style=[(key="display", val="flex"), (key="flex-direction", val="column")], class=[(name="boxed", set=true), (name="boxin", set=true)], text="Hello Fractalide!")~d3_test' -> input page(${ui_js_page})


   'js_create:(type="svg", attr=[(key="width", val="200"), (key="height", val="200")])~create' -> input div(${ui_js_tag}) output -> input page(${ui_js_page})

   'js_create:(type="circle", attr=[(key="r", val="70"), (key="fill", val="yellow")])~create' -> input tag(${ui_js_tag})
   tag() output[create] -> input act(${ip_action}) output -> input div()
   tag() output -> input div()
   'generic_text:(text="insert_text")' -> option act()

   // 'js_create:(name="newdiv", class=[(name="boxin", set=false)])~d3_test' -> input page()

   // 'js_create:(name="newdiv", remove=true)~d3_test' -> input page()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
