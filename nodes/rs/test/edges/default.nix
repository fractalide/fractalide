{ lib, agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = (lib.collect lib.isDerivation edges);
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
