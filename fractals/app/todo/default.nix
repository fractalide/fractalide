{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "f1cd912a61526ed6501381f5d9473608c2c03cf7";
    sha256 = "0a84plbj7yig580ib1536b9qz74yfrk0fmmw36ivip2g7jsgw2i6";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
