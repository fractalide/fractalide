{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ CoreGraph CoreSemanticError ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
