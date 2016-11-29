{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "f4510e74a8286f721799c3b21c8b04c8a77fe221";
    sha256 = "14b8994xwwzmrg752nxqzn1y7195jsvzwhg0lci6h0r81cy46yzy";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
