{ pkgs, support, contracts, components, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "d0e62fa32041dd6584b5c489c3598344cb05fb70";
    sha256 = "0jh10dpq5kf6rqx6bqjdfy1zswqnml8sbsjkff9i4yw4xnzck5kv";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit pkgs support contracts components crates; fractalide = null;}
