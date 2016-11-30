{ pkgs, support, contracts, components, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "1ab98d7108beb7b1dd6aac9e59335c8909c8a29d";
    sha256 = "1srn7lavdia6r80d8mhcnk4q2d4y3vvpx2ww97dhrg40mrh8hix5";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit pkgs support contracts components crates; fractalide = null;}
