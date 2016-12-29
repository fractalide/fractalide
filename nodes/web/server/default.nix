{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ fs_path net_protocol_domain_port net_url ];
  crates = with crates; [ rustfbp capnp iron mount staticfile ];
  osdeps = with pkgs; [ openssl ];
}
