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
    rev = "0e9c626cbeda4e59e8c24255e6c8acf83afa8176";
    sha256 = "17smif5s2q8pb2d7r47zgiagxn5mbm7dj6ybfrih0b000qh96vvq";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
