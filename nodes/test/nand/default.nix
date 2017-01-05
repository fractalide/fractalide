{ subgraph, nodes, edges }:

subgraph {
 src = ./.;
 flowscript = with nodes; with edges; ''
  '${prim_bool}:(bool=true)' -> a nand(${maths_boolean_nand}) output -> input io_print(${maths_boolean_print})
  '${prim_bool}:(bool=true)' -> b nand()
 '';
}
