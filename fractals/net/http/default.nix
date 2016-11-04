{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  repo = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "bb5e7c1f0883d467c6df7b1f4169b3af71b594e0";
    sha256 = "1vs1d3d9lbxnyilx8g45pb01z5cl2z3gy4035h24p28p9v94jx1b";
  };

  /*repo = ../../../../fractals/fractal_net_http;*/

  net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  net_http
