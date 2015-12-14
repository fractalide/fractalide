{ pkgs ? import <nixpkgs> {}}:

let
	callPackage = pkgs.lib.callPackageWith (pkgs // components);
	components = rec {
		boolean-not = callPackage ./boolean/not {};
	};
in components

