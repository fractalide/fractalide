{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_list path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0lfcbplk67wcpzpfy3faaccw5lc6npklkk4l0czky335i0j7kfqx";
}
