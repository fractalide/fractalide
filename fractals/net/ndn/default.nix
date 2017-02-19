{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "d6aeb3401b82fb07e43f32e5678aed4fc6f4fbcc";
    sha256 = "0r3fycik61fjmbybm5m7cky3kbp3anl2digihh008yg7v50s4n4j";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit buffet; fractalide = null;}
