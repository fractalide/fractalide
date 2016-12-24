{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ js_create prim_text ];
  flowscript = with nodes; with edges; ''
  '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td(${ui_js_nodes.flex}) output -> input page(${ui_js_nodes.page})
  '${prim_text}:(text="initial")~create' -> input edit(${ui_js_nodes.edit}) output -> places[1] td()
  '${js_create}:(type="span", text="hello")~create' -> input t(${ui_js_nodes.tag}) output -> places[2] td()
  '';
}
