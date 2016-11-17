{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "35dfd4b97d27e27d019a76d664b1bcd726b25823";
    sha256 = "1ajgd9ya063x20ajxlnrczgsxiqfc4i2ngpw4675wafz832cry7i";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
