{ subgraph, nodes, edges }:

subgraph {
 src = ./.;
 flowscript = with nodes.rs; ''
  true(${maths_boolean_true}) output -> a nand(${maths_boolean_nand})
  false(${maths_boolean_false}) output -> b nand()
  nand() output -> input io_print(${maths_boolean_print})
 '';
}
