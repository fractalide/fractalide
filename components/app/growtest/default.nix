{ stdenv, buildFractalideSubnet, upkeepers
  , app_counter_card
  , ip_action
  , ip_delay
  , ip_replace
  , ui_js
  , nucleus_flow_subnet
  # contracts
  , js_create
  , generic_text
  , app_counter
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   td(${ui_js.flex}) output -> input page(${ui_js.page})
   '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td()

   lr(${ui_js.flex}) output -> places[1] td()
   '${js_create}:(type="div", style=[(key="display", val="flex")])~create' -> input lr()

   button_add(${ui_js.tag}) output -> places[1] lr()
   button_remove(${ui_js.tag}) output -> places[2] lr()
   '${js_create}:(type="button", text="add")~create' -> input button_add()
   '${js_create}:(type="button", text="remove")~create' -> input button_remove()

   dummy()

   gflex(${ui_js.growing_flex}) output -> places[2] td()
   gflex() scheduler -> action sched(${nucleus_flow_subnet})
   sched() outputs[flex] -> places[2] td()
   '${generic_text}:(text="${app_counter_card}")' -> option gflex()
   '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input gflex()

   button_add() output[click] -> input add(${ip_replace}) output -> input gflex()
   button_remove() output[click] -> input minus(${ip_action}) output -> input gflex()
   '${generic_text}:(text="remove")' -> option minus()
   '${app_counter}:(value=0)~add' -> option add()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
