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
    rev = "c519b811c57df55861037de6337a2169fe50e918";
    sha256 = "0x427l560dzwsjalala458wmr478ckckidyqmabsqg0ymvpk7z7b";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
