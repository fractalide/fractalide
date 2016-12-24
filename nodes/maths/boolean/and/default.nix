{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
  a => a nand(${maths_boolean_nand}) output -> input not(${maths_boolean_not}) output => output
  b => b nand()
  '';
}
