{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ fbp_graph ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0zfkg3d2mj8hbb4a626jh920xmnk0xkr1j1n0mvcwkbhqkjjcfd0";
}
