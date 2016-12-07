{ pkgs, support, edges, nodes, crates }:

  let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "7e40e8f24ca6964b773a7b39f75d15dc8ba8ac80";
    sha256 = "023mqljf997rg79hljbqslxky8lgma30v7wh7k7l037ch0rs4z20";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
  in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
