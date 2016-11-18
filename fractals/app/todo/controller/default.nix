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
    rev = "451daa5a1373acef9373cd4dad0d712f764422ab";
    sha256 = "1w2gwkj9k4x0xgqdb69g6l8ccvw9sj5j2sagrbmyjgx4r6ajm3ly";
  };
  /*fractal = ../../../../fractals/fractal_app_todo_controller;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
