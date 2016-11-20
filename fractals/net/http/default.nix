{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "c7879a6f985697f552648bfa95cfcd9a1616d69a";
    sha256 = "01hz4zfys7mp6wfrsg6f2a9b9gq9k0qcfv7w772ybnhmapqc1afb";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
