{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "1d5dap4is35q6n8nziiq0kfafn9nn0rpnmlq42z8n2z9x5rjs5xq";
}
