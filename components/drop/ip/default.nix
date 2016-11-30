{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "188n9p40g0camgxkwy05r79xw2s9gpbqlmyi18wnq17a1f2rd87m";
}
