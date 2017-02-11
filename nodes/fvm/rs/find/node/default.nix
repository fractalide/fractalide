{ rs, edges, mods, pkgs }:

rs.agent {
  src = ./.;
  edges = with edges; [ FsPath FsPathOption ];
  crates = with mods.crates; [ rustfbp capnp ];
  osdeps = with pkgs; [ nix ];
}
