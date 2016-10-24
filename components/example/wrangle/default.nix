{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  repo = fetchFromGitHub {
      owner = "fractalide";
      repo = "frac_example_wrangle";
      rev = "2c62da95fd45bc186d428c648ed8c5b4e4036590";
      sha256 = "0i2a8r7ww1k9ir29cgv69i4076s1h5xc4d617i32q5p8sxhj5h36";
    };
  example_wrangle = import repo {inherit pkgs support contracts components; fractalide = null;};
  /*repo = ../../../../frac_example_wrangle;
  example_wrangle = import repo {inherit pkgs support contracts components; fractalide = null;};*/
  in
  example_wrangle
