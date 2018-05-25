let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "f322df56de6581f5c3cf70994b6d52298ba8a9e7";
    sha256 = "1nijpr4npszk1nia06gzzd5b1mvmkrl0wzk9paay3lhk66xyp419";
  };
in
import pinnedPkgs
