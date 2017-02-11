{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "ebcf49f0e7c35778541a547c87655593b839af9a";
    sha256 = "1i3j2l4afzshax62f80m8r48mhj1wswk857riqwa2mlrglr7dgk5";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
