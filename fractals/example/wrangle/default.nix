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
    rev = "4aaddd85e8523c6955ab9add2a4a8053a1e4ce58";
    sha256 = "1xshhakv5kxdlkcpr5ff7r1x9n486zr4zbv9mr38px7cg9ib7a0a";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
