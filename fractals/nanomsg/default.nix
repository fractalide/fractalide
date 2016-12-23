{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "4eb0d91769513860acb37e11e507c9c4f1c8f2b7";
    sha256 = "0pk8310xjyqfp81fd9md9p7x3zbmwxmc6bfdfbvn3zz80hkd0c1b";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
