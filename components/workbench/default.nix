{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , fetchFromGitHub
  , maths_boolean_print
  , maths_boolean
  , generic_i64
  , ...}:
  let
  /*
  repo = fetchFromGitHub {
      owner = "fractalide";
      repo = "frac_workbench";
      rev = "28342ea221e4e4cf0d7ee751833d4e824a95660f";
      sha256 = "1hwrpbikfrlql91j137kdhb0n8z73zlsc8mrmrc4fhhwff8vf1lz";
    };
    */
  repo = /home/denis/dev/frac/frac_net_hyper;
  external_net_hyper = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  external_net_hyper
