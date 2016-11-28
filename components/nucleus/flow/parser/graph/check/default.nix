{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [ fbp_graph fbp_semantic_error ];
  depsSha256 = "0zfkg3d2mj8hbb4a626jh920xmnk0xkr1j1n0mvcwkbhqkjjcfd0";
}
