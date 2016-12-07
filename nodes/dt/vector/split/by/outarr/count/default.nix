{ agent, edges, crates, pkgs }:

agent  {
  src = ./.;
  edges = with edges; [ file_list ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "11dqabq7307pc7617mbgsils7jkdqr88cxj8z0pq056gxrym0006";
}
