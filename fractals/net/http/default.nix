{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "25a72ffec1e26aa10b475a634af0319889520e3e";
    sha256 = "0f008fgick9gf89l2jgg0g1n0hrfbn7wrrhdgvza9g4k8ss5v98w";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
