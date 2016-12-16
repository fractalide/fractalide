{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ generic_text list_command ];
  crates = with crates; [ rustfbp capnp nom ];
  osdeps = with pkgs; [];
}
