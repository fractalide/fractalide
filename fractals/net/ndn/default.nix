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
    rev = "547b87cae59f799b54fc5d884c82b4ba96650259";
    sha256 = "1x6k7568gar9yk85rz2qa9277ch3af9bczhkvwp0mmlrw8yd8hya";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
