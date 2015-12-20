{ pkgs, lib, components, rustcMaster }:
let
mapping = pkgs.writeTextFile {
  name = "mapping.rs";
  text = ''
use std::collections::HashMap;

#[allow(dead_code)]
fn components() -> HashMap<&'static str, &'static str> {
let mut map  = HashMap::<&str, &str>::with_capacity(${
    (builtins.toString (builtins.length (lib.attrValues components)))});
${lib.concatMapStringsSep "\n"
    (pkg: "map.insert(\"${pkg.name}\", \"${(lib.last (lib.splitString "/" pkg.outPath))}\");")
    (lib.attrValues components)}
map
}
'';
    executable = false;
};
in
pkgs.stdenv.mkDerivation rec {
  name = "fractalide-mappings-${version}";
  version = "2015-12-18";
  unpackPhase = "true";
  buildInputs = [ rustcMaster ];
  installPhase = ''
  mkdir -p $out/{src,lib}
  cp ${mapping} $out/src/mapping.rs
  rustc -C no-stack-check -O --crate-type=rlib $out/src/mapping.rs --out-dir $out/lib/
  '';
}
