{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "0319c4230347387415f482b17659eec057057c51";
    sha256 = "0gyv4w4g589fwaz4nhiy94jj2f2v7b5kb5s2gvkzn7ihd9dwl6h4";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
