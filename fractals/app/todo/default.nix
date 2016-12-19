{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "2d75557606b30704883f733bd8c3843b1e692e62";
    sha256 = "1vgns374554fr1bwylcsik05af51h1ck2a99z2i12brqiimjil1y";
  };*/
  fractal = ../../../../fractals/fractal_app_todo;
in
  import fractal {inherit buffet; fractalide = null;}
