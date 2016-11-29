{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "b839e030710c55852f8abc862ae83a0478e1cf8e";
    sha256 = "1ddqfl6s7ldb6wqb1z99266qkdbjd8m54yckphk2swnxhnb8z9g3";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
