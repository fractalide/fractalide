{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "83706bfd5fe8ffcd7c3919ad5429941b1f39e6ca";
    sha256 = "0dbh5qf8mjgdgcwflacdi8s256dm0lycfsn9kh0217zbri8yacby";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
in
  import fractal {inherit buffet; fractalide = null;}
