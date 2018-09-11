let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "racket2nix";
    rev = "75f84d3708e1155323b0575f34b169d2f22ca369";
    sha256 = "019ad4j19z2gwc4knam2sqi1ybwbyasr81yq8zahj2b2zk4g9ywq";
  };
in
import pinnedPkgs
