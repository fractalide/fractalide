{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "e1883203dc372ed9e4db16dcfde6f0d772184bf2";
    sha256 = "1nplh6j42030j55rng6kzc91b3nny102wyhrsnnly3nfrys11b45";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
in
  import fractal {inherit buffet; fractalide = null;}
