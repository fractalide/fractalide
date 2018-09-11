let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "8345dbd56f0c8164646eb039427c155a51014708";
    sha256 = "0ds08qjpcs1wlpbywbz8bhlla5d2z91137aghhm0m2wqig70rijy";
  };
in
import pinnedPkgs
