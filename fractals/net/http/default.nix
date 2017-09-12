{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "9f79e0459f756104f989fd8ec1b7aab86afed78c";
    sha256 = "1amnjgh32kicbsbh2spznipw2yis9szl16nw85c6ihav0x6m8fnz";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
