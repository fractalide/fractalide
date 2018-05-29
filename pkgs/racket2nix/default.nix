let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "cad00d50227dffa7ef3f2d597a65a735c15ab177";
    sha256 = "04krjqpap791avxl6y954cmkfshm5vgwch9iqm7263gjv49gxsp1";
  };
in
import pinnedPkgs
