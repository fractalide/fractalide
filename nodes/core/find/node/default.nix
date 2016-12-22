{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ path option_path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [ nix ];
}
