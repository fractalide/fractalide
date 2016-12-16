{ agent, edges, crates, pkgs }:

agent  {
  src = ./.;
  edges = with edges; [ file_list ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
}
