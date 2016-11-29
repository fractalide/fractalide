{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ maths_boolean ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "0pzvnvhmzv1bbp5gfgmak3bsizhszw4bal0vaz30xmmd5yx5ciqj";
}
