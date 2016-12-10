{ pkgs, support, edges, nodes, crates }:

  let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "b7dad40094595470c52558c980807a3e232de828";
    sha256 = "1w1sdlr6mxmnjggljr9s9d2b34yr5w263kjljwwwkd0x1i3s8yji";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
  in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
