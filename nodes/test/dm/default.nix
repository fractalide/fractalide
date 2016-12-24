{ subgraph, nodes, edges }:

subgraph {
 src = ./.;
 edges = with edges; [ maths_boolean ];
 flowscript = with nodes; with edges; ''
 '${maths_boolean}:(boolean=false)' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})
 '';
}
