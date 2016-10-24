{ pkgs
  , support
  , contracts
  , components
  , ...}:
  let
  repo = https://github.com/fractalide/frac_example_wrangle/archive/2c62da95fd45bc186d428c648ed8c5b4e4036590.tar.gz;
  example_wrangle = import (fetchTarball repo)  {inherit pkgs support contracts components; fractalide = null;};
  /*repo = ../../../../frac_example_wrangle;
  example_wrangle = import repo {inherit pkgs support contracts components; fractalide = null;};*/
  in
  example_wrangle
