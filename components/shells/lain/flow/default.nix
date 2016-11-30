{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ file_desc list_command ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0f3smv1bz24i592mq4ypdnmwdjbc7rwlqhrj90mxmiz15li6ga5k";
}
