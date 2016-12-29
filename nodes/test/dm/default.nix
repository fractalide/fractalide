{ subgraph, nodes, edges }:

subgraph {
 src = ./.;
 edges = with edges; [ prim_bool ];
 flowscript = with nodes; with edges; ''
 '${prim_bool}:(boolean=false)' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})
 '';
}
