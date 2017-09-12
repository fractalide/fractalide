{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "3991d621331913de0a90888074a43e55e322a95d";
    sha256 = "1cdiyv8lfsawp9h2s8x2whhp2563krmhsgba8zg470hwkpkbwa0k";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
