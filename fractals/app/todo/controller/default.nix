{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "2d9adc743029eb46387cbc3f4fb093c817eb353a";
    sha256 = "178nd51zl4d6i52bs8m5w480kfgmidh5nvk8lp49h3kc67kqgi1i";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
