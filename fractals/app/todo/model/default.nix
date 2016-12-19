{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "6452f15b376c8648d8ed54d6b1d6f034d93aeeef";
    sha256 = "2w1sdlr6mxmnjggljr9s9d2b34yr5w263kjljwwwkd0x1i3s8yji";
  };*/
  fractal = ../../../../../fractals/fractal_app_todo_model;
in
  import fractal {inherit buffet; fractalide = null;}
