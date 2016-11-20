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
    rev = "2ea1b5f2e3158c24f7fd190f4886783c5783b67e";
    sha256 = "0z02gj2flrh6yd8bpf8bzadyz1833a7hgks0xg2488j212c0fdyk";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
