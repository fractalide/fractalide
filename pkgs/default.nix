{ pkgs ? import ./nixpkgs.nix
, fetchFromGitHub ? (pkgs {}).fetchFromGitHub
, rustOverlay ? fetchFromGitHub {
    owner  = "mozilla";
    repo   = "nixpkgs-mozilla";
    rev    = "7e54fb37cd177e6d83e4e2b7d3e3b03bd6de0e0f";
    sha256 = "1shz56l19kgk05p2xvhb7jg1whhfjix6njx1q4rvrc5p1lvyvizd";
  }
, racket2nix ? import ./racket2nix { racket = (pkgs {}).racket-minimal; }
}:

pkgs {
  overlays = [
    (import (builtins.toPath "${rustOverlay}/rust-overlay.nix"))
    (self: super: rec {
      rust = let
        fromManifestFixed = manifest: sha256: { stdenv, fetchurl, patchelf }:
          self.lib.rustLib.fromManifestFile
            (fetchurl { url = manifest; sha256 = sha256; })
            { inherit stdenv fetchurl patchelf; };
        rustChannelOfFixed = manifest_args: sha256: fromManifestFixed
          (self.lib.rustLib.manifest_v2_url manifest_args) sha256
          { inherit (self) stdenv fetchurl patchelf; };
        channel = rustChannelOfFixed
          { date = "2018-04-01"; channel = "nightly"; }
          "186lzxrff9pyakgcf7gv604abl7dcjmy69ilk762anmwya3lgjmj";
      in {
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
