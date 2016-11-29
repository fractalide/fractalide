{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ file_desc path file_error ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "1xs37xa191j84wnn7xdx2ji6p10kzihlnhca8a5jrmkxlnzqrlhh";
}
