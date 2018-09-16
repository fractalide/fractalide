let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "f44516247f57be18bf49a66d82df9b90cbcd6671";
    sha256 = "15ixl1yaz2hq0i67yb3g0cc4in5fpzk44j56js9cqwlqykfskdgl";
  };
in
import pinnedPkgs
