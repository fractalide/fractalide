{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "25dac92e4badcb7de58da21903965891189c5044";
    sha256 = "0h47ddzz7xvgbz4jyrq5n8cb6q6yvnxf81qbvds4053mb9bkibyj";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit buffet; fractalide = null;}
