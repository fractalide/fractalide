{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0nh85zb5336s8h1b9pljqacd3n9wrqnnkzflqp8kjrgc5rsgq3rd";
}
