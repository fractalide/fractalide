{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "024dd9c6fe3c58b98ec2219c9cce6ea0dc1f08c5";
    sha256 = "13xkgssws2xf537nhiq13f7mpjra3d3ppfdwhhmcd6znaar1jr5b";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
