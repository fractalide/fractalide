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
      owner = "dmichiels";
      repo = "frac_net_http";
      rev = "064c5a2cec0c1bdf189339bbeac272ece0cad2d5";
      sha256 = "1fy0zwkfzyxxkpyb1ljcp0dkbcapli5gwkkdlcrwkbfss7fgihws";
    };
  /* repo = /home/denis/dev/frac/frac_net_hyper; */
  external_net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  external_net_http.test
