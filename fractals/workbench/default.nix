{ buffet }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "e9eda9875bd9eac41a6a7fb575ae89b32a4ba9e0";
    sha256 = "1df7l826mrx27xb6czhkcj2s6nq1fzby1x98c211visv1i62npkf";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
