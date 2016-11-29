{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ maths_number ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "028xyjzfbiz7mxhdmwb55dg5npr1flwhbjkzsrlj4f92cq8n7vr7";
}
