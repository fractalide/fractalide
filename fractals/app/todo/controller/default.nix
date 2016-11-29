{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_controller";
    rev = "a6352d60ceb731bfb91a382d7ab84b8bc6914714";
    sha256 = "0k18mcx7mc5n1i2p6dl3cfryfdqh9v49hqlmrb0zld6kp79lxkcv";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_controller;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
