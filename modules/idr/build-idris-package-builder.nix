pkgs: attrs:
with pkgs;
let
  defaultAttrs = {
    builder = "${bash}/bin/bash";
    args = [ ./builder.sh ];
    setup = ./setup.sh;
    baseInputs = [ gnutar gzip gnumake gcc binutils coreutils gawk gnused gnugrep patchelf findutils haskellPackages.idris ];
    buildInputs = [ gmp ];
    system = builtins.currentSystem;
  };
in
derivation (defaultAttrs // attrs)
