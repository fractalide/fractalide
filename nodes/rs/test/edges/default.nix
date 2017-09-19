{ lib, agent, edges, mods, pkgs }:

agent {
  src = ./.;
  capnp_edges = (lib.collect lib.isDerivation edges.capnp);
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
