{ buffet }:

let
  /*fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "5162f49b88156d41b4f9b3c64093ded955c6f9ed";
    sha256 = "2irv9v998qxsc7z3zdmwmyb998wpqfja8hpqhw4p16syv0jqk5ns";
  };*/
  fractal = ../../../../fractals/fractal_example_wrangle;
in
  import fractal {inherit buffet; fractalide = null;}
