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
    rev = "0a66423be9bee7904964adec111e87ee99980fea";
    sha256 = "0ar3kyjs265pz6x2lg8hwcf42vaxa87rq31baqj2i5hill554iw4";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
