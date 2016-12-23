{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "cabcd2953bc510fec5c64dec03cbf3c167ff9d3b";
    sha256 = "0yrwhyaw4vdh06h8vppza25xmhhsiqg1jy7qg9003fsfkk0qrkfx";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
in
  import fractal {inherit buffet; fractalide = null;}
