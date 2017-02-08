{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "ed49b44e6f8762b8b6ca8f4f8970de1784bc26cc";
    sha256 = "0wrszmk234fm8pwcl303cjg0wsf82zrsjpsqmj98cp6xpwpwqs5n";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
in
  import fractal {inherit buffet; fractalide = null;}
