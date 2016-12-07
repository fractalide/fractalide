{ pkgs, support, edges, nodes, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "f30da9816809c6b26774a355de760bfa68d425ce";
    sha256 = "0kd4gzxx6pm4dlsiqksg3anx3yg46w7rxdfcazxmn6783bfhff0a";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
