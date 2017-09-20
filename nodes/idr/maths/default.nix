{ agent, edges, mods }:

agent {
  src = ./.;
  edges = with edges.idr; [ TestVect ];
  mods = with mods.idr; [ prelude ];
}
