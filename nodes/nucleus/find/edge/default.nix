{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ path option_path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0crny6f03bzgjhcl2kyc2cas8mmnyfdcnac1q9kkjwf9cq9kxnaw";
}
