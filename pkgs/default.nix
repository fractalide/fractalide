{ pkgs ? import ./nixpkgs
, system ? builtins.currentSystem
, fetchFromGitHub ? (pkgs {}).fetchFromGitHub
, fetchurl ? (pkgs {}).fetchurl
, rustOverlay ? fetchFromGitHub {
    owner  = "mozilla";
    repo   = "nixpkgs-mozilla";
    rev    = "7e54fb37cd177e6d83e4e2b7d3e3b03bd6de0e0f";
    sha256 = "1shz56l19kgk05p2xvhb7jg1whhfjix6njx1q4rvrc5p1lvyvizd";
  }
, racket2nix ? import (import ./racket2nix) { inherit system; }
}:

pkgs {
  inherit system;
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
          { date = "2018-05-30"; channel = "nightly"; }
          "06w12izi2hfz82x3wy0br347hsjk43w9z9s5y6h4illwxgy8v0x8";
      in {
        rustc = channel.rust;
        inherit (channel) cargo;
      };
      inherit racket2nix;
      inherit (racket2nix) buildThinRacketPackage;
      rustPlatform = super.recurseIntoAttrs (super.makeRustPlatform rust);
      fractalide = ((self.buildThinRacketPackage (builtins.path {
        name = "fractalide";
        path = ./..;
        filter = (path: type:
          let basePath = baseNameOf path; in
          (null != builtins.match ((toString ./..) + "(/info.rkt|/(modules|edges|nodes)(/rkt(/.*)?)?)") path) &&
          (type != "symlink" || null == builtins.match "result.*" basePath) &&
          (null == builtins.match ".*[.]nix" basePath) &&
          (null == builtins.match "[.].*[.]swp" basePath) &&
          (null == builtins.match "[.][#].*" basePath) &&
          (null == builtins.match "[#].*[#]" basePath) &&
          (null == builtins.match ".*~" basePath)
        );
      })).overrideRacketDerivation (oldAttrs: {
        doInstallCheck = true;
        installCheckFileFinder = ''
          find $env/share/racket/pkgs/*/modules/rkt/rkt-fbp/agents -name '*.rkt' |
            xargs grep -Zl 'module[+] test'
        '';
      })).overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs or [] ++ [ self.makeWrapper ];
        inherit (self) expect graphviz;
        postInstall = oldAttrs.postInstall or "" + ''
          wrapProgram $env/bin/hyperflow --prefix PATH ":" $graphviz/bin
          wrapProgram $env/bin/cardano-wallet --prefix PATH ":" $expect/bin
        '';
      });
    })
  ];
}
