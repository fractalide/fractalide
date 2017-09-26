with import ../../../modules/idr/default.nix { pkgs = import <nixpkgs>{}; };
with import <nixpkgs> {};

let
  with_packages = import ../../../modules/idr/with-packages.nix {
    inherit stdenv;
    idris = haskellPackages.idris;
  };
  idrisWith = with_packages [ prelude base contrib effects pruviloj ];
in
  idrisWith
