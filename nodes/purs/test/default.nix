{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ PrimBool ];
  mods = with mods.purs; [ console ];
}
