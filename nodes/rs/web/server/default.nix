{ agent, edges, mods, pkgs }:

agent {
  src = ./.;
  mods = with mods.rs; [ rustfbp iron mount staticfile ];
  osdeps = with pkgs; [ openssl ];
}
