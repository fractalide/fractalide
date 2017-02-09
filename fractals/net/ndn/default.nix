{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "184151556f00dc6ff38d18eccbabe04c5f2c408e";
    sha256 = "00f814l5d44vy5ip0xvdlgagqxf11yxxg2s9msmbdhm1d65gh9yk";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit buffet; fractalide = null;}
