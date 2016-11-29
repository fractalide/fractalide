{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ list_text ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "17ypb1hvyrsvkb248s6yknybrmdj0gjsi9k212ydys17i3i5xhq9";
}
