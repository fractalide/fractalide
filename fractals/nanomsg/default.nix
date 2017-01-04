{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "86471eac3fcd4776818c37fb13bc2133ce08dd43";
    sha256 = "0jhd0acy81yf9g6j1aqa0l6scb5ac4s2wxp3i9adjppf6b5j04sy";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
