{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "e32ff1eab1c830f06625dfc49a26499ad4bf3e23";
    sha256 = "12lhav80w8w2kyk2vy03viqnqbiq3xq57cg9w0khff3rk9gk7v57";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
