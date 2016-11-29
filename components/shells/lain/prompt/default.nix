{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "098m76zz83lw96aksj0p7hbg5lpbb5wd0wi791a7qj8hrh4jsfjd";
}
