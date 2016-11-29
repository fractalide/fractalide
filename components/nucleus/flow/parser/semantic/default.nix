{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ fbp_semantic_error fbp_graph fbp_lexical ];
  crates = with crates; [];
  depsSha256 = "0gx5d8cxk7mca9sj118302xww9vv6z59mxl4wbas3nfggip36fy6";
}
