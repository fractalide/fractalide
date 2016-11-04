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
    rev = "336398c39ee00de5a9fcdff5149d2ccd5a2efc4f";
    sha256 = "062yh5zcilf7wqydcb4jgjlhb4993lggfysm27sbnanxsbjar44r";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
