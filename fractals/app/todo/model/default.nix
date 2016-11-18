{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "c88d5662b933d5f1a8ed272bb6a6ab25698ebb1e";
    sha256 = "01ialzp5i3sb3fncsd7v4s3dk99d36n7k3q7pkhim8zl6lmcqrxr";
  };
  /*fractal = ../../../../fractals/fractal_app_todo_model;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
