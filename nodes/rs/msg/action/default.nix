{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  mods = with mods.rs; [ rustfbp ];
  osdeps = with pkgs; [];
}
