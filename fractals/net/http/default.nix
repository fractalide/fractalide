{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "6794bfd7e35fa449602e7f04d7e5e411f5c5b40e";
    sha256 = "02b6kbmdppbcr1iipywycrivsqw433qkvlryj7v4i9pjka88f16x";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
