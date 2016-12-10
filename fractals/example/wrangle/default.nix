{ pkgs, support, edges, nodes, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "59cebfc89ba7f2187df56cdba8f48b4d457331b0";
    sha256 = "1irv9v998qxsc7z3zdmwmyb998wpqfja8hpqhw4p16syv0jqk5ns";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
