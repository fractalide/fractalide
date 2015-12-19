{ pkgs, lib, components, wget, firefox, chromium  }:
let
mapping = pkgs.writeTextFile {
	name = "mapping.txt";
	text = lib.concatMapStringsSep "\n" (pkg: "${pkg.name} ${pkg.outPath}") (lib.attrValues components);
	executable = false;
};
in
pkgs.stdenv.mkDerivation rec {
	name = "mapping-${version}";
	version = "2015-12-18";
	unpackPhase = "true";
	installPhase = ''
		mkdir -p $out/etc/
		cp -r  ${mapping} $out/etc/mapping.txt
		cat $out/etc/mapping.txt
	'';
}

