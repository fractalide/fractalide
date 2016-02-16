{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, ...}:
let
fractalide-src = pkgs.stdenv.mkDerivation {
  name = "fractalide-src";
  src = ./.;
  unpackPhase = "true";
  installPhase = "
  mkdir -p $out/src
  cp -R $src/* $out/src
  ";
};
fvm-shell = pkgs.writeTextFile {
  name = "fvm-shell";
  executable = true;
  text =
  ''#!${pkgs.bash}/bin/bash
    s=${pkgs.nix}/bin/nix-shell
    e=${pkgs.nix}/bin/nix-env
    exec $s ${fractalide-src}/src/default.nix --command \
    "export NIX_REMOTE=daemon
      export NIX_PATH='$NIX_PATH'
      export NIX_BUILD_SHELL=${pkgs.bash}/bin/bash
      exec $e -i -f ${fractalide-src}/src/fvm.nix --argstr debug true --argstr fbp $@
      "'';
    };

fractalide = pkgs.stdenv.mkDerivation {
  name = "fractalide";
  unpackPhase = "true";
  installPhase = ''
  mkdir -p $out/bin
  cp ${fvm-shell} $out/bin/fractalide
  '';
};
in
fractalide
