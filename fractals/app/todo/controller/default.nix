{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "74c1718452bbd2a4f6ef0af34bf0d030b1358d93";
    sha256 = "19z485bp8lf2dw42i7c510irm6m7yjxzwns12pbs1964b8lsr7m5";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
in
  import fractal {inherit buffet; fractalide = null;}
