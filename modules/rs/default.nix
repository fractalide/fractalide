{ buffet }:
let
  fetchzip = buffet.pkgs.fetchzip;
  release = buffet.release;
  verbose = buffet.verbose;
  buildRustCode = buffet.support.node.rs.buildRustCode;
  crates = import ./crates { inherit buildRustCode fetchzip release verbose; };
in
crates
