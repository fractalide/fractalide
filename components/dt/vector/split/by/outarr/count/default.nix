{ component, contracts, crates }:

component  {
  src = ./.;
  contracts = with contracts; [ file_list ];
  crates = with crates; [];
  depsSha256 = "11dqabq7307pc7617mbgsils7jkdqr88cxj8z0pq056gxrym0006";
}
