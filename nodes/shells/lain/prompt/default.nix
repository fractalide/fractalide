{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ generic_text ];
  crates = with crates; [ rustfbp capnp toml libc copperline ];
  osdeps = with pkgs; [];
  depsSha256 = "098m76zz83lw96aksj0p7hbg5lpbb5wd0wi791a7qj8hrh4jsfjd";
}
