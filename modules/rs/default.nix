{ buffet }:
let
  crates = import ./crates {
    inherit (buffet) edgesModule;
    inherit (buffet.pkgs) buildRustCrate fetchgit lib;
    inherit (buffet.pkgs.stdenv) buildPlatform edgesModule;
  };
in
crates
