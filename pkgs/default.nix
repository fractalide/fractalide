let
  pkgs = import <nixpkgs>;
  rustOverlay = (pkgs {}).fetchFromGitHub {
    owner  = "mozilla";
    repo   = "nixpkgs-mozilla";
    rev    = "4779fb7776c3d38d78b5ebcee62165e6d1350f74";
    sha256 = "04q6pwlz82qsm81pp7kk7i6ngrslq193v5wchdsrdifbn8cdqgbs";
  };
in (pkgs {
  overlays = [
    (import (builtins.toPath "${rustOverlay}/rust-overlay.nix"))
    (self: super: rec {
      rust = with super.rustChannels; {
        rustc = nightly.rust;
        inherit (nightly) cargo;
      };
      rustPlatform = super.recurseIntoAttrs (super.makeRustPlatform rust);
    })
  ];
})
