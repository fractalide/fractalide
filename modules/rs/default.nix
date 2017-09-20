{ buffet }:
let
  fetchzip = buffet.pkgs.fetchzip;
  release = buffet.release;
  verbose = buffet.verbose;
  build-rust-package = buffet.support.node.rs.build-rust-package;
  crates = import ./crates { inherit build-rust-package fetchzip release verbose; };
in
crates
