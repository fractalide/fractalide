{ subgraph, imsg, nodes, edges }:

let
  PrimBool = imsg {
    class = edges.PrimBool;
    text = "(bool=true)";
    option = "create";
  };
in
subgraph {
 src = ./.;
 flowscript = with nodes.rs; ''
  '${PrimBool}' -> a nand(${maths_boolean_nand}) output -> input io_print(${maths_boolean_print})
  '${PrimBool}' -> b nand()
 '';
}
