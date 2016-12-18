{ buffet }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "f466b5feb9e8195bdf417f4a451ef5f0f6e0d785";
    sha256 = "0nfp222xyrk34nz4cb6dcbh9fhdadalp0h4h0rqqrzs3aczx9mqw";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit buffet; fractalide = null;}
