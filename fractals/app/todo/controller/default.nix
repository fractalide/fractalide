{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "cabcd2953bc510fec5c64dec03cbf3c167ff9d3bcabcd2953bc510fec5c64dec03cbf3c167ff9d3b";
    sha256 = "1sxh741jrwfbc1dfdb807frqpbx3ba9srl36qghg0jg9xj3kq0ii";
  };*/
  fractal = ../../../../../fractals/fractal_app_todo_controller;
in
  import fractal {inherit buffet; fractalide = null;}
