{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , fetchFromGitHub
  , ...}:
  let
  repo = fetchFromGitHub {
    owner = "fractalide";
    repo = "frac_net_http";
    rev = "04292f7a020a9f700a48fb805536b8b05da3267b";
    sha256 = "03m7mr3j27msk3jnnb317kymw6v1b3gm1131mpx20lb9q6rg8rkz";
  };
  /*
  repo = /home/denis/dev/frac/frac_net_hyper;
    */
  external_net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  external_net_http.test
