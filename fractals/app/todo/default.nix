{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "d1325020574d0aade7930439aec2d6b004329adc";
    sha256 = "1m5pql94pghrir817g7f1v2dj0g8jk4m44y7z7vf8pf3dqha775c";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
