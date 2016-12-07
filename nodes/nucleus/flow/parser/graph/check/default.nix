{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fbp_graph fbp_semantic_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0zfkg3d2mj8hbb4a626jh920xmnk0xkr1j1n0mvcwkbhqkjjcfd0";
}
