{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "2ed334df5c1a2b2bb1435da1ef5666e0971732b7";
    sha256 = "044zs4z0mhs4nrpdg5xib4zr5dms68b4rfp5685il6ji17wj6371";
  };*/
  fractal = ../../../../fractals/fractal_net_http;
in
  import fractal {inherit buffet; fractalide = null;}
