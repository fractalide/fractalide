{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "3f524628f78fbbc0bc493fbdbd7a4c1fa3a7ff0d";
    sha256 = "1arknchza70n55vibrwk5s4ld9dfh6a4hjf3s7r3qjyrxj4mx7a3";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
