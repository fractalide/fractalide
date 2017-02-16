{ agent, edges, mods }:

agent {
  src = ./.;
  edges = with edges; [ PrimBool ];
  mods = with mods.purs; [ console ];
}
