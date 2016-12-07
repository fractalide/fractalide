{ pkgs, support, edges, nodes, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "1ca3dfa258a97e308caba3681161d7d3df9f2627";
    sha256 = "03gig0c010ir5nzzi9wyzld5viqbrgppkbbz7zgwsrpa3a16jamm";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
