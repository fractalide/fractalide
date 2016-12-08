{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
  input => input clone(${ip_clone})
  clone() clone[1] -> a nand(${maths_boolean_nand}) output => output
  clone() clone[2] -> b nand()
  '';
}
