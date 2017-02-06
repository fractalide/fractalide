{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ FsPath NetProtocolDomainPort NetUrl ];
  crates = with crates; [ rustfbp capnp iron mount staticfile ];
  osdeps = with pkgs; [ openssl ];
}
