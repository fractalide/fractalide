{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_desc path file_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "1xs37xa191j84wnn7xdx2ji6p10kzihlnhca8a5jrmkxlnzqrlhh";
}
