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
      rev = "6b38ded9fafaa3adbd73190e3e9233ca7070ab4a";
      sha256 = "1yvim78ivm9cbvbvd2vg9s1b4q3ccp6is34h2a592z32gzsvwvf9";
    };
  external_net_http = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  external_net_http
