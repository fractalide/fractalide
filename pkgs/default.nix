{ bootPkgs ? import <nixpkgs> {}
, pkgs ? import (bootPkgs.fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs";
    rev    = "9d0b6b9dfc92a2704e2111aa836f5bdbf8c9ba42";
    sha256 = "096r7ylnwz4nshrfkh127dg8nhrcvgpr69l4xrdgy3kbq049r3nb";
  })
, fetchFromGitHub ? (pkgs {}).fetchFromGitHub
, rustOverlay ? fetchFromGitHub {
    owner  = "mozilla";
    repo   = "nixpkgs-mozilla";
    rev    = "7e54fb37cd177e6d83e4e2b7d3e3b03bd6de0e0f";
    sha256 = "1shz56l19kgk05p2xvhb7jg1whhfjix6njx1q4rvrc5p1lvyvizd";
  }
, racket2nix ? import (fetchFromGitHub {
    owner  = "clacke";
    repo   = "racket2nix-clacke";
    rev    = "622cb6c52fe59b82dea88ec75a2d5d2a98e408b6";
    sha256 = "1qvfrab24zsm1ygnqcin9vjqv63a0swqiwdr3im8f2v2kciklwkx";
  }) { racket = (pkgs {}).racket-minimal; }
}:
pkgs {
  overlays = [
    (import (builtins.toPath "${rustOverlay}/rust-overlay.nix"))
    (self: super: rec {
      rust = let channel = self.rustChannelOf { date = "2018-04-01"; channel = "nightly"; }; in {
        rustc = channel.rust;
        inherit (channel) cargo;
      };
      inherit racket2nix;
      inherit (racket2nix) buildRacket;
      rustPlatform = super.recurseIntoAttrs (super.makeRustPlatform rust);
      fractalide = self.buildRacket {
        package = builtins.filterSource
          (path: type: type != "symlink" || null == builtins.match "result.*" (baseNameOf path))
          ./..;
      };
    })
  ];
}
