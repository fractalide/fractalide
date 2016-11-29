{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ file_list path ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "0lfcbplk67wcpzpfy3faaccw5lc6npklkk4l0czky335i0j7kfqx";
}
