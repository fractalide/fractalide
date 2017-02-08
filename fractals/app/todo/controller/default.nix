{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "d65da9afbcd9c0b18e236f2b0814d6856b308a16";
    sha256 = "10a6rnxyd29ms5k0hyik9fw0ncqzvavlw4kfd5xgl2jb0f1w3s8m";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
in
  import fractal {inherit buffet; fractalide = null;}
