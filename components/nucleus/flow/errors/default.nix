{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ fbp_graph fbp_semantic_error file_error ];
  crates = with crates; [];
  depsSha256 = "1f1ibcyc60j7xrq1r2lnfc5v0aik52fbn5m8qi1sla84xc0j61lf";
}
