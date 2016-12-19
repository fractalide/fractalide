{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "c18f30a57c1a32a1342297ffdf89ed69de2ea870";
    sha256 = "0pab5ajp4nc14297vysbbhxddhk5krwq96kfap7ldmpd48ac8wgl";
  };*/
  fractal = ../../../fractals/fractal_workbench;
in
  import fractal {inherit buffet; fractalide = null;}
