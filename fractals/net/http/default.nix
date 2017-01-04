{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "588c7596e53aa19f845cca2f27e20c20dc9695d3";
    sha256 = "1l1f3sq69ajg6pgy3pnp3hp94yi4hx84hsnf1fssj8qawqa68xq7";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit buffet; fractalide = null;}
