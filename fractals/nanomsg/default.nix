{ pkgs, support, contracts, components, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "cdefd2570aa403978eb259b0535c428f156c8960";
    sha256 = "1jbd0g7qi15a91f7hnjrhvjxmdrk0573z8vqm9xa8sb3m9acg4ds";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit pkgs support contracts components crates; fractalide = null;}
