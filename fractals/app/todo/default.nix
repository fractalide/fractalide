{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "df06e33810a8f66af9761f1c3429979a39731ae0";
    sha256 = "17h1kdsabxa3q15y7r32zx12hxhy3g6sq2wmmszzw3qfml3wzwgn";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
