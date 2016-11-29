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
    rev = "c0c9f62516a7859ecffdb0021869789f5e935a52";
    sha256 = "10kmmagmbvhvkxznxlp7mykcrrf1ci6qfcav9v6s7jsss6mp7487";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
