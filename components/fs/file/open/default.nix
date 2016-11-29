{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ file_desc path file_error ];
  crates = with crates; [];
  depsSha256 = "1xs37xa191j84wnn7xdx2ji6p10kzihlnhca8a5jrmkxlnzqrlhh";
}
