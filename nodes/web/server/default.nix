{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ path domain_port url ];
  crates = with crates; [ rustfbp capnp iron mount staticfile ];
  osdeps = with pkgs; [ openssl ];
  depsSha256 = "01260pbn4dciqgsb1xyfk5jd3wsi8cdvfs107kh2d9wy5imac9an";
}
