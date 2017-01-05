{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "d1585af8b872cd293be32e2cacc9fe60d1ba0ae3";
    sha256 = "17g56v43s4xylnafw8ck8m3x2gp2pwm0k33261lml1hag5rrknwx";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
