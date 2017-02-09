{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "98049276a501cb5607a0b50169d2abcfddf1ee25";
    sha256 = "0xf57hxfgpgnhjy2j3yviqhjb6qcqxn14kl6937vmhwnwpp22f9d";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
