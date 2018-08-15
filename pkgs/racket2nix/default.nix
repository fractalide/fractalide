let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "b36a72442b487e6d8f7c8f58f84a1d1f7b13fcb8";
    sha256 = "146cahd80ib2nrx7402q1p3m0p3gb6qi5lkbnr92bpfxadwy3g3c";
  };
in
import pinnedPkgs
