let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "8a6ed9183628fe278bf3c7d66418e7d41bb47789";
    sha256 = "0ds1194fhdg2bwsdmqqj7l2xm4cz82083k8dps9iw2w7qh33pswm";
  };
in
import pinnedPkgs
