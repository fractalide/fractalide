{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "36c4a538f9cafbf1d5caf8f4c28b1d95bfd1ada7";
    sha256 = "0j4kjn18ajfpy92sffx34m7xwq6hq0c1qdvp9lc7k4zpglk3y6j4";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
in
  import fractal {inherit buffet; fractalide = null;}
