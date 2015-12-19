{ pkgs, lib, components, rustcMaster }:
let
mapping = pkgs.writeTextFile {
	name = "mapping.rs";
	text = ''
use std::collections::HashMap;
fn main() {
let mut components = HashMap::with_capacity(${(builtins.toString (builtins.length (lib.attrValues components)))});
${lib.concatMapStringsSep "\n" (pkg: "components.insert(\"${pkg.name}\", \"${pkg.outPath}\");")(lib.attrValues components)}
}
	'';
	executable = false;
};
in
pkgs.stdenv.mkDerivation rec {
	name = "mapping-${version}";
	version = "2015-12-18";
	unpackPhase = "true";
	buildInputs = [ rustcMaster ];
	installPhase = ''
	mkdir -p $out/etc
	mkdir -p $out/bin
	rustc --crate-type=lib ${mapping} -o $out/bin
	cp -r  ${mapping} $out/etc/mapping.rs
	'';
}

