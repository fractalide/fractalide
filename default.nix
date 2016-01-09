{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildType ? "--release"
, ...}:
let
callPackage = lib.callPackageWith (pkgs // support // components // contracts);
support = rec {
  cargo = pkgs.cargo;
  rustcMaster = pkgs.rustcMaster;
  rustRegistry = callPackage ./build-support/rust-packages.nix {};
  buildFractalideComponent = callPackage ./build-support/buildFractalideComponent.nix {inherit buildType;};
  buildFractalideContract = callPackage ./build-support/buildFractalideContract.nix {};
  buildFractalideSubnet = callPackage ./build-support/buildFractalideSubnet.nix {};
  buildRustPackage = callPackage ./build-support/buildRustPackage.nix {};
  genName = callPackage ./build-support/genName.nix {};
  capnpc-rust = callPackage ./build-support/capnpc-rust {};
  filterContracts = List: map (name: (lib.attrValues (lib.filterAttrs (n: v: n == name) contracts))) List;
};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
in {
  inherit components contracts support;
  rust-component-lookup = callPackage ./mappings/rust-component-lookup.nix { inherit components; };
  rust-contract-lookup = callPackage ./mappings/rust-contract-lookup.nix { inherit contracts; };
}


