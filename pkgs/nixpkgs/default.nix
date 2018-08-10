let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "d1ae60cbad7a49874310de91cd17708b042400c8";
    sha256 = "0a1w4702jlycg2ab87m7n8frjjngf0cis40lyxm3vdwn7p4fxikz";
  };
in
import pinnedPkgs
