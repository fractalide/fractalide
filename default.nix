{ pkgs ? import <nixpkgs> {}}:

let
	callPackage = pkgs.lib.callPackageWith (pkgs // components);
	components = rec {
		cargo = pkgs.cargo;
		rustcMaster = pkgs.rustcMaster;
		rustRegistry = callPackage ./build-support/rust-packages.nix {};
		buildFractalideComponent = callPackage ./build-support {
			inherit cargo rustcMaster;
		};
		boolean-not = callPackage ./boolean/not {};
	};
in components

