{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "aeee0cdfb9abb03b8c588e869e1990a5955126eb";
    sha256 = "1nfp222xyrk34nz4cb6dcbh9fhdadalp0h4h0rqqrzs3aczx9mqw";
  };*/
  fractal = ../../../../fractals/fractal_net_ndn;
in
  import fractal {inherit buffet; fractalide = null;}
