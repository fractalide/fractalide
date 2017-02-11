{ lib, agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = (lib.collect lib.isDerivation edges);
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
