let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "67e4cac07ddeffc51da4a29d9c3b7c7d36129d92";
    sha256 = "055y52sns7ng5mwxvmwibngxq17ygdqf8y4vzgimygdmh94dbakm";
  };
in
import pinnedPkgs
