{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ command generic_text];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "06a1570ql1dn18zim3k00akv6951wgh07ghzh4xik8bp9b9kh8vw";
}
