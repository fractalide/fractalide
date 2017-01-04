{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "4fa2b30ba9cde1392adacb3fa0512cc938441818";
    sha256 = "2j8ci01arqx8mp1lvwb7zp4zfgbpc5ki8mp4y3dpglkmsgx4zk6g";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
in
  import fractal {inherit buffet; fractalide = null;}
