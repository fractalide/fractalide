{ pkgs, lib, components, rustcMaster }:
let
mapping = pkgs.writeTextFile {
	name = "mapping.rs";
	text = ''
use std::collections::HashMap;
#[allow(dead_code)]
fn components() {
let mut components = HashMap::with_capacity(${(builtins.toString (builtins.length (lib.attrValues components)))});
${lib.concatMapStringsSep "\n" (pkg: "components.insert(\"${pkg.name}\", \"${pkg.outPath}\");")(lib.attrValues components)}
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
	mkdir -p $out/{etc,lib}
	cp -r  ${mapping} $out/etc/mapping.rs
	rustc -C no-stack-check -O --crate-type=rlib $out/etc/mapping.rs --out-dir $out/lib/
	'';
}

