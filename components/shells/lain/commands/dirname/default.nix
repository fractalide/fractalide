{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ command generic_text];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "06a1570ql1dn18zim3k00akv6951wgh07ghzh4xik8bp9b9kh8vw";
}
