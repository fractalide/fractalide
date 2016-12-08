{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "188n9p40g0camgxkwy05r79xw2s9gpbqlmyi18wnq17a1f2rd87m";
}
