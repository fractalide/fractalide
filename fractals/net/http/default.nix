{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "4a6b52592e4381b89db8697d4c0922ae89c6e2c4";
    sha256 = "0xr8wlz1a3qc3775b4j4g3k6dq8ipg044jcch6ypxw4bc3189b53";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
