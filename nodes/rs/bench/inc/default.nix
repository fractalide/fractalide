{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.rs; [ TestPair ];
  mods = with mods.rs; [ rustfbp ];
  osdeps = with pkgs; [];
}
