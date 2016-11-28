{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ path option_path ];
  crates = with crates; [];
  depsSha256 = "0njzr825krfwd81bljd79365wgdlzqnq4kbydmcq356gaq33rlna";
}
