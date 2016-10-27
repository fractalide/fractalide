{ pkgs
  , support
  , contracts
  , components
  , ...}:
  let
  /*repo = fetchFromGitHub {
      owner = "fractalide";
      repo = "frac_net_http";
      rev = "d8fdc3869e50cfe413c73b57425cc3de84cb87dc";
      sha256 = "2l2nyx931vnyq1hdni6ny63zw5mk6yw56l3ppgkfgjrvhwviw40f";
    };*/
  repo = ../../../../frac_net_http;
  net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  net_http
