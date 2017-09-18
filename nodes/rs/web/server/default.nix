{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  edges = with edges.capnp; [ FsPath NetProtocolDomainPort NetUrl ];
  mods = with mods.rs; [ rustfbp capnp iron mount staticfile ];
  osdeps = with pkgs; [ openssl ];
}
