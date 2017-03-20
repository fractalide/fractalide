{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "fb87bc8f5a693b0a3775baa22de1fad0c83e0a79";
    sha256 = "0nz77kpcw03inn4ha756f9gaq6308ij7rs6a5ncy56rhgxvikxdm";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
