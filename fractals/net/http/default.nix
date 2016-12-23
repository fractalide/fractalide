{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "7c5ee75c5de33a0d825234bf7e6d4456037434d7";
    sha256 = "0kmpkj914ikn0zyml8d801z163c3vqz6vizyryq1g9slkp595syb";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
