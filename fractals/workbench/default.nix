{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "4e7a28c77fff712773a6333e802b4203f10f05c9";
    sha256 = "0imrpamw42qqmv3qfv25hbvz7fmx0y62yv1arvx4kvi9ppgqdyad";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
