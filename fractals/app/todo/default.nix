{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "6a0426d2d32fa71ab94e0f55b61f52654af3c38f";
    sha256 = "01bqx9zdhxl6k6wnl5zz79kgckvnf9bmkjshh4bl9iqir15pxrz2";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
