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
    rev = "98ce218eeb9ace10caa5bec72531b531dcd54712";
    sha256 = "17r25h3bvp8jy9pkww5gki543r5vdjsdxchwyni7g6c9hhph6yfc";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
