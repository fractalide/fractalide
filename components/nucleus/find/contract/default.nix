{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [ path option_path ];
  depsSha256 = "0njzr825krfwd81bljd79365wgdlzqnq4kbydmcq356gaq33rlna";
}
