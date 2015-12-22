{ pkgs, lib, components, buildRustPackage }:
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
buildRustPackage rec {
  version = "2015-12-22";
  name = "mapping";
  src = ./.;
  depsSha256 = "11d7ld7prr2fjnx47x4dn8p1naryfbbkymx6q001lh811aj752y1";
  postPatch = ''
    mkdir -p src $out/{src,lib}
    echo src/mapping.rs $out/src/mapping.rs | xargs -n 1 cp ${mapping}'';
}
