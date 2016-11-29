{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text list_command ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "11lbiw2mqj9ihx5h04pwq3i2drfw55vqya5r15m6ik118nxqxvh5";
}
