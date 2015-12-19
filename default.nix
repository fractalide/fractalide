{ pkgs ? import <nixpkgs> {}}:
let
callPackage = pkgs.lib.callPackageWith (pkgs // components);
components = rec {
	cargo = pkgs.cargo;
	rustcMaster = pkgs.rustcMaster;
	rustRegistry = callPackage ./build-support/rust-packages.nix {};
	buildFractalideComponent = callPackage ./build-support { inherit cargo rustcMaster rustRegistry;};
	mapping = callPackage ./components/mapping.nix { inherit components; };
	#---------------> Rust flow-based programming components hereafter
	boolean-not = callPackage ./components/boolean/not {};
}; in components

