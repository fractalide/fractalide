{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "cea4cbd792ae1c95b493580eb0496cd47cfdf875";
    sha256 = "1q4x70ic63c2c9lj2b1gnczmd4vz54h74j0ajgm1kf6x3xcrimhp";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
