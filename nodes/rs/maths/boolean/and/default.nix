{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes.rs; ''
  a => a nand(${maths_boolean_nand}) output -> input not(${maths_boolean_not}) output => output
  b => b nand()
  '';
}
