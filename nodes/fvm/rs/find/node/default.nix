{ support, edges, mods, pkgs }:

support.rs.agent {
  src = ./.;
  edges = with edges; [ FsPath FsPathOption ];
  mods = with mods.rs; [ rustfbp capnp ];
  osdeps = with pkgs; [ nix ];
}
