{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "f25eb7750f9072ed3f0cfdceb26aff34f2fabf3d";
    sha256 = "0j74fvddraalh23lg91458ai6lw1s2pmchvs2mxjbyh0dl5rmkyr";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit buffet; fractalide = null;}
