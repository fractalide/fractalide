{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
   input => input in_dispatch(${msg_dispatcher}) output -> input out_dispatch(${msg_dispatcher}) output => output

   td(${ui_js_nodes.flex}) output -> input out_dispatch()

   lr(${ui_js_nodes.flex}) output -> places[0] td()

   button(${ui_js_nodes.tag}) output -> places[0] lr()
   button2(${ui_js_nodes.tag}) output -> places[2] lr()
   text(${ui_js_nodes.tag}) output -> places[1] lr()

   in_dispatch() output[model] -> input viewer(${app_counter_viewer}) label -> input text()

   button() output[click] -> input minus(${msg_action}) output -> input out_dispatch()
   button2() output[click] -> input add(${msg_action}) output -> input out_dispatch()
   '${prim_text}:(text="minus")' -> option minus()
   '${prim_text}:(text="add")' -> option add()


   input(${ui_js_nodes.tag}) output -> places[1] td()

   input() output[input] -> input delta(${msg_action}) output -> input out_dispatch()
   '${prim_text}:(text="delta")' -> option delta()

   viewer() delta -> input input()

   in_dispatch() output[create] -> input create(${app_counter_create})
   create() label -> input text()
   create() delta -> input input()
   create() minus -> input button()
   create() plus -> input button2()
   create() td -> input td()
   create() lr -> input lr()

   in_dispatch() output[delete] -> input td()
   '';
}
