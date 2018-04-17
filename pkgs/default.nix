{ pkgs ? import <nixpkgs>
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
    rev    = "20354a92230bf5c9aeb53aa5e6d9720dbd8380e5";
    sha256 = "1z2ni1b3zh8hx8wnzdipyi7ys06zwm4kqzql6d0555dy3y18g70m";
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
