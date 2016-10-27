{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  repo = fetchFromGitHub {
      owner = "fractalide";
      repo = "frac_ui_js";
      rev = "90f330622a1bff13edcad822004d40e6adb2ee26";
      sha256 = "0wshdxkwgk5xmigdc3f95ac03na8dllhp3pnzz5l3gz7h0nkz50r";
    };
  /*repo = ../../../../frac_ui_js;*/
  example_wrangle = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  example_wrangle
