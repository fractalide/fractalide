{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , fetchFromGitHub
  , ...}:
  let
  /*repo = fetchFromGitHub {
      owner = "fractalide";
      repo = "frac_db_rusticdb";
      rev = "28342ea221e4e4cf0d7ee751833d4e824a95660f";
      sha256 = "1hwrpbikfrlql91j137kdhb0n8z73zlsc8mrmrc4fhhwff8vf1lz";
    };*/
  repo = ../../../../frac_db_rusticdb;
  rusticdb = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  rusticdb
