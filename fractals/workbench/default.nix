{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "ba640660c965436fe3def128121cb86f750ae59f";
    sha256 = "0s8dbj8imj0nqj5j7288m6pdk95nrcgxid77bcja2kgprp2pd0hc";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
