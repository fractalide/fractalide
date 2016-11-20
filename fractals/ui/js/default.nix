{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "528564912edf66862628c16beb985bdbbc88d641";
    sha256 = "09dlk7n0c3bz841bh5n43g25mz8j4l3b0gsf0a3db481rsjf5kzz";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
