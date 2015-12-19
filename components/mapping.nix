{ pkgs, lib, components, wget, firefox, chromium  }:
let

mapping = pkgs.writeTextFile {
	name = "mapping.txt";
	text = lib.concatMapStringsSep "\n" (pkg: "${pkg.name} ${pkg.outPath}") [ wget chromium firefox ];
# the above works but I need the function to run against all the components like this:
#	text = lib.concatMapStringsSep "\n" (pkg: "${pkg.name} ${pkg.outPath}") (lib.toList components);
# the above throws an error:
# error: attribute ‘name’ missing, at /mapping.nix:8:47
# --------
# How does one convert the components into a list?
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

