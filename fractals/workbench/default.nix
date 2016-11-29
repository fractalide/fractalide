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
    rev = "e900c9a7ec7ffcd7531083190d897312bc31174b";
    sha256 = "0x1mpqg8hmda5g6lrfjfmm1avaxds2dsq32vaz342gwsxzrzjdm5";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
