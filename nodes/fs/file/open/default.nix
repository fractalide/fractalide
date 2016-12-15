{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ file_desc path file_error ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0hnx03n80qkwccdxzsydb81q75v4h0qypynm9v2z7f936fibjra5";
}
