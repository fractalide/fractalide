{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "89592d1d7018905865fbe501dda814d95ca86c73";
    sha256 = "09vslzz31bw9bf4vyngfdaq3ldj6kxbl1snk2g4kch6a5rcqcx3x";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
in
  import fractal {inherit buffet; fractalide = null;}
