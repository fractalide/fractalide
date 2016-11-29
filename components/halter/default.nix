{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "0gvr58pk14xiflicp4q33gpdr762a5hfvdzzmr35jld4685cdj3w";
}
