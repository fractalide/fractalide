{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "2f80bfe9cb86e5a8818b73a9a67fa99146301710";
    sha256 = "1ynsl1152lv5whrls54mrcw3nvn4x2b4sj31nm9dk84sph61ydmb";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
in
  import fractal {inherit buffet; fractalide = null;}
