{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes.rs; ''
  input => input clone(${msg_clone})
  clone() clone[1] -> a nand(${maths_boolean_nand}) output => output
  clone() clone[2] -> b nand()
  '';
}
