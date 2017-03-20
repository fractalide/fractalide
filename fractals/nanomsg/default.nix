{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "09ae8e6908d2c1e8fcc02580fd226d85b0b9892b";
    sha256 = "1gxc6vxszgbl5wxn6683gh49378hjzhyc2z4bz6n4lcv4zw67kaw";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
