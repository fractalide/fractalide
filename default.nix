{ pkgs ? import <nixpkgs> {}}:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support // components);
support = {
	cargo = pkgs.cargo;
	rustcMaster = pkgs.rustcMaster;
	rustRegistry = callPackage ./build-support/rust-packages.nix {};
	buildFractalideComponent = callPackage ./build-support/buildFractalideComponent.nix {};
	buildRustPackage = callPackage ./build-support/buildRustPackage.nix {};
	capnpc-rust = callPackage ./build-support/capnpc-rust {};
};
components = rec {
	boolean-not = callPackage ./components/boolean/not {};
	boolean-nand = callPackage ./components/boolean/nand {};
};
in {
	inherit support components;
	mapping = callPackage ./components/mapping.nix { inherit components; };
}
