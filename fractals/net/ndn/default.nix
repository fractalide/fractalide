{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "09e16f26e7deeb1454312f695887e29465c0e58c";
    sha256 = "09qm6awhlybzbch48si6vw8q2n5dlc6avb1xyznfa0jywkh5wm3x";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
