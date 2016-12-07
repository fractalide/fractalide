{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
   list_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "17ypb1hvyrsvkb248s6yknybrmdj0gjsi9k212ydys17i3i5xhq9";
}
