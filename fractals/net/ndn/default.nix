{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "dde21c6264bcdc381bc2686bcb629f9cabf0fbcf";
    sha256 = "045pr7rwdbn741jcpv78b5wxxw75smh2l6ng8fyw6ika23vzq5yv";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit buffet; fractalide = null;}
