{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith (buffet.pkgs);
  /*nix-crates-index = ../../../nixcrates/nix-crates-index;*/
  nix-crates-index = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "nix-crates-index";
    rev = "960231687094f70263c46212d5b506ff48fb0658";
    sha256 = "08h14y6w2ab9ygla42593i2dzxp81dnkfq5qm74gmp7cfl049hgg";
  };
  origCrates = buffet.pkgs.recurseIntoAttrs (callPackage nix-crates-index {});
  rustfbp = import ./rustfbp { inherit crates; crate = buffet.support.rs.crate; };
  crates = origCrates // { inherit rustfbp; };
in
  crates
