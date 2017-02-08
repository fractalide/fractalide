{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "140e0e89facf0fc0891e30e380c0c9e78870a1bf";
    sha256 = "1kz5r552xwq7j62ifrdninn46yzvcn8l98yddcadn9m3381jqllj";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit buffet; fractalide = null;}
