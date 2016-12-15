{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "00cld3a98sim55782p2g997c4rd5dnsbmhkddf6kavwpscq141sz";
}
