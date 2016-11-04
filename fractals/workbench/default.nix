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
    rev = "3098eb66924b4150054fdbdcf08e0036bb6d6ae2";
    sha256 = "12k2hjlpmd4z5may6876a6zgb2qyb3cnwq50wiaaxncnplwah15i";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
