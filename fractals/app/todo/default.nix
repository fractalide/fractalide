{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "720bd572be75337b2d63d49ff4965a0b0d1ad9ea";
    sha256 = "148xm6hjhq93v7zhagzmc4y18aq7nb19h6fvb9zzqbxw82zv0mli";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
