{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "f7924bc87eeed9248c88136144b83c751a2f2237";
    sha256 = "1gbkvy0gn5hfq7n6mr63gaqd4dmwvaq1g93isl379cbxkj2f34n5";
  };*/
  fractal = ../../../../fractals/fractal_ui_js;
in
  import fractal {inherit buffet; fractalide = null;}
