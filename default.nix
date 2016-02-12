{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, ...}:
let
fractalide = pkgs.stdenv.mkDerivation {
  name = "fractalide";
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
    b=${pkgs.nix}/bin/nix-build
    exec $s ${fractalide}/src/default.nix --command \
    "exec $s ${fractalide}/src/fvm.nix --argstr fbp $@ --command \
      "eval $postUnpack; eval $postUnpack; eval $buildPhase; eval $installPhase; exec result/bin/fvm $@; return""'';};

fvm = pkgs.stdenv.mkDerivation {
  name = "fvm-shell";
  unpackPhase = "true";
  installPhase = ''
  mkdir -p $out/bin
  cp ${fvm-shell} $out/bin/fvm
  '';
};
in
fvm
