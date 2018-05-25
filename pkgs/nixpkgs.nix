let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "c29d2fde74d03178ed42655de6dee389f2b7d37f";
    sha256 = "1v1cnlhqp6lcjbsakyiaqk2mm21gdj74d1i7g75in02ykk5xnc7k";
  };
in
import pinnedPkgs
