{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "5f31448c33801d8eb325ea2bc1c039619cda0b20";
    sha256 = "1parlpqh8ypqv0d1mp7jb9ryz80hpyxq8cpbr8jqffpcc8iyvmvj";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
