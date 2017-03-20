{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith (buffet.pkgs);
  /*nix-crates-index = ../../../nixcrates/nix-crates-index;*/
  nix-crates-index = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "nix-crates-index";
    rev = "e7f75876c0f3fc855c821d82bcb97ebae7d0e783";
    sha256 = "0s4zhzn45n6r2w7id1z55vqdgqj1jlcf6sxlk1z2wcbap8c01gvl";
  };
  origCrates = buffet.pkgs.recurseIntoAttrs (callPackage nix-crates-index {});
  rustfbp = import ./rustfbp { inherit crates; crate = buffet.support.rs.crate; };
  crates = origCrates // { inherit rustfbp; };
in
  crates
