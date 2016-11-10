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
    rev = "b9590b6648348503b5f2ff5f7f130ed79432c722";
    sha256 = "0jz58mmax5n5nxrxpicn8jzica736gbl7qf87k4yycmzr26xwfqa";
  };

  /*
  repo = ../../../../fractals/frac_net_hyper;
  */

  net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  net_http
