{ pkgs, support, contracts, components, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "e3bf51a7040f4f41c737bc0f316adf0d351d37ab";
    sha256 = "0zq6q7137p3fk0vcvnq2nqkljlcvxzsxkycfhpb054xlfdjcnkjn";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit pkgs support contracts components crates; fractalide = null;}
