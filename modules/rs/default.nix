{ buffet }:
let
  crates = import ./crates {
    inherit (buffet) edgesModule;
    inherit (buffet.pkgs) buildRustCrate buildRustCrateHelpers cratesIO fetchgit lib makeWrapper stdenv;
    inherit (buffet.pkgs.rust) rustc;
    inherit (buffet.pkgs.stdenv) buildPlatform;
  };
in
crates
