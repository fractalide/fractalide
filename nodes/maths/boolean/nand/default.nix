{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ maths_boolean ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "11pd9fl05xd5ra327fmi2cv497xl4c16rg4iqj34izwzqii832hk";
}
