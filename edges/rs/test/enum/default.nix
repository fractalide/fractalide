{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.rs; [ ];
}
