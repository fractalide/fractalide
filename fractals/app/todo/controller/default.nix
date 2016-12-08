{ pkgs, support, edges, nodes, crates }:

  let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "54192998e43372e4fd406d3e4735229fb88dafd3";
    sha256 = "0zplniallzkgl3mfi02588pgka78h775drxrr34kdd80b2vwjgs1";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
  in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
