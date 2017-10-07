pkgs: idris: attrs:
with pkgs;
let
  defaultAttrs = {
    builder = "${bash}/bin/bash";
    args = [ ./builder.sh ];
    setup = ./setup.sh;
    baseInputs = [ gnutar gzip gnumake gcc binutils coreutils gawk gnused gnugrep patchelf findutils pkgconfig idris ];
    system = builtins.currentSystem;
  };
in
derivation (defaultAttrs // attrs)
