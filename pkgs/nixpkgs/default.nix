let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "4477cf04b6779a537cdb5f0bd3dd30e75aeb4a3b";
    sha256 = "1i39wsfwkvj9yryj8di3jibpdg3b3j86ych7s9rb6z79k08yaaxc";
  };
in
import pinnedPkgs
