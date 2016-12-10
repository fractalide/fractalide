{ pkgs, support, edges, nodes, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "ffdbc28df1d3e49ffd4297a87f254a9bdb2dafde";
    sha256 = "0gpdm0a237jw259xarpn7r8iapqrrzyh6bpaq05jm3fdfvp2y19s";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
