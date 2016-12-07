{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ generic_text list_command ];
  crates = with crates; [ rustfbp capnp nom ];
  osdeps = with pkgs; [];
  depsSha256 = "11lbiw2mqj9ihx5h04pwq3i2drfw55vqya5r15m6ik118nxqxvh5";
}
