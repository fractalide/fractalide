{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "9f830fd3b70c3946d68ba6c3d5195768b8d93031";
    sha256 = "1vky6g3bbkx001yg3qaykd0nkgabscf2ikl2b9rbybwvkia70rjg";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
