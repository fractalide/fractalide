{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "48d216fb1673ea43a47ad289e20d489305b22be6";
    sha256 = "1s46rj0w89wz0k3fyz52byd00g9q4gp1zgkyspp5zmmpj0d794nc";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
