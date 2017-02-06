{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ FsPath FsPathOption ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [ nix ];
}
