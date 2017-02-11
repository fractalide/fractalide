{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ FsPath FsListPath ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
