{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "8590c912bbc6794529fc462626e3547bf32cba9e";
    sha256 = "19l6z1pmddby8lzdsf57m7k478m8fyqpliypfbgc74gcpwl85mc7";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
