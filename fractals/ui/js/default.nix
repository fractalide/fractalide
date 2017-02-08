{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "45a472f56470ba85bd8ed30b83cfea57d6c5fd3d";
    sha256 = "0w62zx0cbmgybdx5yqd2xpqr972gfvkp3l4zpbfnynrp0l0kk68w";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
