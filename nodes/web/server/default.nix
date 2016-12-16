{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ path domain_port url ];
  crates = with crates; [ rustfbp capnp iron mount staticfile ];
  osdeps = with pkgs; [ openssl ];
}
