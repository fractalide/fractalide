{ agent, edges, mods }:

agent {
  src = ./.;
  edges = with edges; [ ];
  mods = with mods.idr; [ prelude ];
}
