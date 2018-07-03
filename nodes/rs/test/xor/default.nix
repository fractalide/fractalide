{ subgraph, nodes, edges }:

subgraph {
 src = ./.;
 flowscript = with nodes.rs; ''
  true(${maths_boolean_true}) output -> a xor(${maths_boolean_xor})
  false(${maths_boolean_false}) output -> b xor()
  nand() output -> input io_print(${maths_boolean_print})
 '';
}
