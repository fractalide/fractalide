{ subgraph, imsgs, nodes, edges }:

subgraph rec {
 src = ./.;
 imsg = imsgs {
   edges = with edges; [ PrimBool ];
 };
 flowscript = with nodes; ''
  '${imsg "PrimBool"}:(bool=true)' -> a nand(${maths_boolean_nand}) output -> input io_print(${maths_boolean_print})
  '${imsg "PrimBool"}:(bool=true)' -> b nand()
 '';
}
