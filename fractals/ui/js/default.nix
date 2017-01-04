{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "5c65449be5521bf39ca8745af6532eeee959ecaa";
    sha256 = "002zm456rwxlwarhhw76khvrb4slhw90i9xfrfqr4lc1w4js0x96";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
