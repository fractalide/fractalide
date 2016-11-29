{ component, contracts, crates, pkgs }:

component  {
  src = ./.;
  contracts = with contracts; [ file_list ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "11dqabq7307pc7617mbgsils7jkdqr88cxj8z0pq056gxrym0006";
}
