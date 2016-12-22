{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''

   td(${ui_js_nodes.flex}) output -> input page(${ui_js_nodes.page})
   '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td()

   lr(${ui_js_nodes.flex}) output -> places[1] td()
   '${js_create}:(type="div", style=[(key="display", val="flex")])~create' -> input lr()

   button_add(${ui_js_nodes.tag}) output -> places[1] lr()
   button_remove(${ui_js_nodes.tag}) output -> places[2] lr()
   '${js_create}:(type="button", text="add")~create' -> input button_add()
   '${js_create}:(type="button", text="remove")~create' -> input button_remove()

   dummy()

   gflex(${ui_js_nodes.growing_flex}) output -> places[2] td()
   gflex() scheduler -> action sched(${core_subgraph})
   sched() outputs[flex] -> places[2] td()
   '${generic_text}:(text="${app_counter_card}")' -> option gflex()
   '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input gflex()

   button_add() output[click] -> input add(${msg_replace}) output -> input gflex()
   button_remove() output[click] -> input minus(${msg_action}) output -> input gflex()
   '${generic_text}:(text="remove")' -> option minus()
   '${app_counter}:(value=0)~add' -> option add()

   '';
}
