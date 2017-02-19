{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "9aed257cb2cc81b58a84ce3ffcf2d23b3c41e15e";
    sha256 = "0c1rw6z4ahla5nwy29ddiqsmhyrnzga7v965j8zy5v13gmb1yhh3";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
