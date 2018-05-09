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
    owner  = "fractalide";
    repo   = "racket2nix";
    rev    = "f694823e1bf959a11f717e60b4e95bc0185f4fc0";
    sha256 = "1b1gwbjp91i555dy18shfyfsp272qdwhqi72pzl09lfl14d5z37r";
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
