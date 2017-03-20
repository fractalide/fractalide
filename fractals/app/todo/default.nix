{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "4cb7d0d2021866d3e94fbaed49a0907c5c296443";
    sha256 = "0whiq6spcs256c55bkwl8bjibz8abs7qymms6rn6dcqym5597vl1";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
