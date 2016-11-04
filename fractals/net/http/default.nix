{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  /*repo = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "6bb7246d18d420b57a7c8e1f67bd7bafbfb7b19f";
    sha256 = "14z603f2g2niphsqhclnzkr7i6nx8f3db1dci9h7vy5dq5fmb27j";
  };*/

  repo = ../../../../fractals/fractal_net_http;

  net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  net_http
