{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "721356afdd95b0022a473e56d960564500dcd512";
    sha256 = "1j8ci01arqx8mp1lvwb7zp4zfgbpc5ki8mp4y3dpglkmsgx4zk6g";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
in
  import fractal {inherit buffet; fractalide = null;}
