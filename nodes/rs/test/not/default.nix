{ subgraph, nodes, edges }:

subgraph {
 src = ./.;
 flowscript = with nodes.rs; ''
  '${PrimBool}' -> input not(${maths_boolean_not}) output -> input io_print(${maths_boolean_print})
 '';
}
