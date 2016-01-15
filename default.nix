{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildType ? "--release"
, rustfbpPath ? "false"
, ...}:
let
callPackage = lib.callPackageWith (pkgs // support // components // contracts);
support = rec {
  cargo = pkgs.cargo;
  rustcMaster = pkgs.rustcMaster;
  rustRegistry = callPackage ./build-support/rust-packages.nix {};
  buildFractalideComponent = callPackage ./build-support/buildFractalideComponent.nix {inherit lib buildType rustfbpPath;};
  buildFractalideContract = callPackage ./build-support/buildFractalideContract.nix {};
  buildFractalideSubnet = callPackage ./build-support/buildFractalideSubnet.nix {};
  buildRustPackage = callPackage ./build-support/buildRustPackage.nix {};
  genName = callPackage ./build-support/genName.nix {};
  capnpc-rust = callPackage ./build-support/capnpc-rust.nix {};
  filterContracts = List: map (name: (builtins.head (builtins.head (lib.attrValues (lib.filterAttrs (n: v: n == name) contracts))))) List;
};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
rust-component-lookup = callPackage ./mappings/rust-component-lookup.nix { inherit components; };
rust-contract-lookup = callPackage ./mappings/rust-contract-lookup.nix { inherit contracts; };
in {
  fractalide-toml = import ./mappings/fractalide-toml.nix{inherit pkgs rust-component-lookup rust-contract-lookup;};
}


