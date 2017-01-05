{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "131d42ea1da9d0fcf0c7948687e203894dd32251";
    sha256 = "0hdfkd5k1qdws1vwgrwqzpnc48qk2lgrisbz54jm2kbypj22bf9c";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
