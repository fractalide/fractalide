{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
  a => input not2(${maths_boolean_not}) output -> b and(${maths_boolean_and})
  b => input not1(${maths_boolean_not}) output -> a and() output -> input not3(${maths_boolean_not}) output => output
  '';
}
