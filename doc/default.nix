{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "fractalide_manual";

  buildInputs = with pkgs; [ asciidoctor ];

  src = pkgs.lib.sourceFilesBySuffices ../. [".adoc"];

  installPhase = ''
    mkdir -p $out/share/doc/fractalide
    asciidoctor doc/index.adoc -o $out/share/doc/fractalide/index.html

    mkdir -p $out/share/doc/fractalide/highlight
    cp -r ${./highlight}/* $out/share/doc/fractalide/highlight
  '';
}
