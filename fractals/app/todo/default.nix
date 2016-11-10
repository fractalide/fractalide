{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  repo = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "d9e9624168a196cfb326e976fbda5324c6230557";
    sha256 = "0m4vbgk5gakl7a86ydzfqcf66w84mrvwmzxwgvbwnjbvhn056db4";
  };

  /*
  repo = ../../../../fractals/fractal_app_todo_backend;
  */

  app_todo = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  app_todo
