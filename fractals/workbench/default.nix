{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "4bdcdefb2691e86397b627acef587be5940fe795";
    sha256 = "1wfnd7h8ramiw69xds4ilz25czqcqgl2rbv7svzz50y5fh2pbbf9";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
