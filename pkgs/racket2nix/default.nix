let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "138fdfde9362f3a4cfff7a57b689afa77da72cbf";
    sha256 = "0dpcc945mwvqbs8609gn5cbgj6q9hsqxrgcbdxbj7jy0dgyrpi33";
  };
in
import pinnedPkgs
