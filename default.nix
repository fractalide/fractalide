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
  not = callPackage ./components/maths/boolean/not {};
  nand = callPackage ./components/maths/boolean/nand {};
  add = callPackage ./components/maths/number/add {};
};
in {
  inherit support components;
  mapping = callPackage ./mapping { inherit components; };
}
