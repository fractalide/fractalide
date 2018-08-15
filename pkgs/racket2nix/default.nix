let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "refs/pull/155/head";
    sha256 = "08wdwz6h69sl62iccfspwac1nbhwb1nd36mks2hb0sbwi1kh954y";
  };
in
import pinnedPkgs
