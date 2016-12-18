{ buffet }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "d253006f4883d8333c8841c67927d72e65a7de3f";
    sha256 = "0334xc6lz8qlbw8gxhvhsyl7ca7fbryy2iwrydc9a78825mm46al";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
