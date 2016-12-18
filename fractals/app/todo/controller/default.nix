{ buffet }:

  let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "59330da444b5f0d98eb3e35a7ccef3d1c1122e4f";
    sha256 = "0sxh741jrwfbc1dfdb807frqpbx3ba9srl36qghg0jg9xj3kq0ii";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
  in
    import fractal {inherit buffet; fractalide = null;}
