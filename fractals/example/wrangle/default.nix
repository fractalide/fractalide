{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_example_wrangle";
    rev = "5f58f094451f5c2368e7e29c5e5c4b6e9e3c591b";
    sha256 = "0j6k743bm5rbr14hvm6di8c12lvz30s8cc6a5ikshq8gi0vysl60";
  };
  /*fractal = ../../../../fractals/fractal_example_wrangle;*/
in
  import fractal {inherit buffet; fractalide = null;}
