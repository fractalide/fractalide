let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "b1f25241bf4b5aefd518ed99dd283bde05350117";
    sha256 = "19cc0qiqmbbmbdqrk438pn200nvnj3phdhj4sy5av3b6kv785i33";
  };
in
import pinnedPkgs
