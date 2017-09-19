{ agent, edges, mods }:

agent {
  src = ./.;
  edges = with edges.idr; [ ];
  mods = with mods.idr; [ prelude ];
}
