let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "1bf18e4c852c52e13842e71f70dec1752bb4297b";
    sha256 = "1hw8czvgismzmr79rwhfm3dv98x5nbql98gwvnmmbbzj60sb7vpm";
  };
in
import pinnedPkgs
