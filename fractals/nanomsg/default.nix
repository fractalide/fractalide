{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "7348c4bd6130458c7bf0f0119c54d99285f58f97";
    sha256 = "11kdz5hcalki3fv89mbhv8rmkcjc83jhh2835iwdihffv0mm0fx5";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
