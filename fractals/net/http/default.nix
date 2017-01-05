{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "ae1cc5c96c2a803c885c5294a50b85e85f29ef6b";
    sha256 = "1kc226gqarqlrw1m7jnaxa0z8alcbd76h20x69q1r166dznwzsca";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
