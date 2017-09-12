{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "1393fae895b3e5f431df416334e5e7daa08ba6af";
    sha256 = "0faqr02qnm84xg6v299h249q5ndbv3xb5qm5czwqff4hj331m3vs";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
