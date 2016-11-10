{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "d9e9624168a196cfb326e976fbda5324c6230557";
    sha256 = "0m4vbgk5gakl7a86ydzfqcf66w84mrvwmzxwgvbwnjbvhn056db4";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
