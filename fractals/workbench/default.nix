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
    rev = "528eef3de3aeb1340710ecdade561d3e6a2a3f9c";
    sha256 = "1lmyzqk0dqsbhd6g2c1k0412723jfgqgckyl9ppvcm16183wp7d4";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
