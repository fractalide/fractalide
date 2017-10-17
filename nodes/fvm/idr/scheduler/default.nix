{ support, edges, mods }:

support.node.idr.agent {
  src = ./.;
  edges = with edges; [ ];
  mods = with mods.idr; [ prelude ];
}
