{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "68aeab22ccc609a457c021306a5785bd168f191a";
    sha256 = "0v99gqjhcvxbff957ch9ghz37mm7fgy9wj2lzvq42gfxrb3fvzly";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
