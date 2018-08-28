let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "8eedab8676476f730c2de2905c3c1377c7bad82c";
    sha256 = "09c8w5c79559lpvp4ghf9dbnywdddykv4irm8b9ykzv01qbwr4gw";
  };
in
import pinnedPkgs
