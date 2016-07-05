{ stdenv, buildFractalideSubnet, upkeepers
  , app_counter_card
  , ip_action
  , ip_delay
  , ip_replace
  , ui_js_flex
  , ui_js_edit
  , ui_js_growing_flex
  , ui_js_tag
  , ui_js_page
  , development_fbp_subnet
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   td(${ui_js_flex}) output -> input page(${ui_js_page})
   'js_tag:(type="div", css=[(key="display", value="flex"), (key="flex-direction", value="column")])~create' -> input td()

   lr(${ui_js_flex}) output -> places[1] td()
   'js_tag:(type="div", css=[(key="display", value="flex")])~create' -> input lr()

   button_add(${ui_js_tag}) output -> places[1] lr()
   button_remove(${ui_js_tag}) output -> places[2] lr()
   'js_tag:(type="button", content="add")~create' -> input button_add(${ui_js_tag})
   'js_tag:(type="button", content="remove")~create' -> input button_remove(${ui_js_tag})

   gflex(${ui_js_growing_flex}) output -> places[2] td()
   gflex() scheduler -> action sched(${development_fbp_subnet})
   sched() outputs[flex] -> places[2] td()
   'generic_text:(text="${app_counter_card}")' -> option gflex()
   // 'generic_text:(text="${ui_js_edit}")' -> option gflex()
   'js_tag:(type="div", css=[(key="display", value="flex"), (key="flex-direction", value="column")])~create' -> input gflex()

   button_add() output[click] -> input add(${ip_replace}) output -> input gflex()
   button_remove() output[click] -> input minus(${ip_action}) output -> input gflex()
   'generic_text:(text="remove")' -> option minus()
   'app_counter:(value=0)~add' -> option add()
   // 'generic_text:(text="initial")~add' -> option add()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
