{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "c3cf71e8c9735f70bf1230e7945de34c7ff3329e";
    sha256 = "1kffymn5h590fnw9all89ia8g7a6sgy2i5381zb85xv6bf722hm4";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit buffet; fractalide = null;}
