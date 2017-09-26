{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "e695380a59c4e1de9df3ff2063364fd385b5e4c6";
    sha256 = "1p16vz81jivglrjwsbhgy40848xdaq0magkiiaq0h1cvbkvx5gv1";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
