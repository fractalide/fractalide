{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ path option_path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [ nix ];
  depsSha256 = "1zl6yl2wd235icqwpgcp4sq2qz4c0qfl7g68xza3dm87bc3p36kn";
}
