{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "2458018028e149c2b558206201be29b6be68ea32";
    sha256 = "0ai78pkcfv943q57h49303fbaqpbhmidfiamh5fkc2is7hi9s6sc";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
  in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
