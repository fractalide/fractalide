{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "7d847c8cb2717e0f770fb386b66168cf4bcde664";
    sha256 = "1mk0d61n6jc5sbd3v8y87k9wy1k5qvaaq00qd5v068zdvjzzkaal";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit buffet; fractalide = null;}
