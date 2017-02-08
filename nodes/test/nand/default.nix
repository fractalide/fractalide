{ subgraph, imsgs, nodes, edges }:

let
  True = imsgs {
    class = edges.PrimBool;
    text = "(bool=true)";
    option = "create";
  };
in
subgraph {
 src = ./.;
 flowscript = with nodes; ''
  '${True}' -> a nand(${maths_boolean_nand}) output -> input io_print(${maths_boolean_print})
  '${True}' -> b nand()
 '';
}
