{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "caca6f95fcc7822c247173beb67fbfa0101a82eb";
    sha256 = "1w2i645l2rr2cmvsv09gaqrzm6p0r0jkjx95r1fsqf60fap6f8rg";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
