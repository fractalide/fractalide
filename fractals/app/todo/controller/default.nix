{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "9fc95691143020ed7581f7271709d11a0da296fc";
    sha256 = "0a5j52jlmmz6h4ri3xadl0ddxpqh0fal9n3pj582wghdb62r3j8i";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
in
  import fractal {inherit buffet; fractalide = null;}
