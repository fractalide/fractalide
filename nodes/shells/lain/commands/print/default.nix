{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ generic_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0nh85zb5336s8h1b9pljqacd3n9wrqnnkzflqp8kjrgc5rsgq3rd";
}
