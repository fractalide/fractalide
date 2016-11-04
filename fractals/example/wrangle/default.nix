{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "1624322af132d638373d4bd2283eba213e903a6d";
    sha256 = "1n84g09k0rh4v9spr3bac0vn79wnrcgbmmxni3mc7banyx31mqql";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
