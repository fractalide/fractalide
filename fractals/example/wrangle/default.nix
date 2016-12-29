{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "947baf1a28875cb4192acc2716991f160e3ebe36";
    sha256 = "0vkpcdmpx744ihcwi0v8xs85c6jj5pv9drni6r8rn8zyazaybxgl";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit buffet; fractalide = null;}
