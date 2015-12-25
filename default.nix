{ pkgs ? import <nixpkgs> {},
lib ? pkgs.lib}:
let
callPackage = lib.callPackageWith (pkgs // support // components // contracts);
support = rec {
  cargo = pkgs.cargo;
  rustcMaster = pkgs.rustcMaster;
  rustRegistry = callPackage ./build-support/rust-packages.nix {};
  buildFractalideComponent = callPackage ./build-support/buildFractalideComponent.nix {};
  buildRustPackage = callPackage ./build-support/buildRustPackage.nix {};
  capnpc-rust = callPackage ./build-support/capnpc-rust {};
  filterContracts = List:  map (name: (lib.attrValues (lib.filterAttrs (n: v: n == name) contracts))) List;
};
contracts = rec {
  number = callPackage ./contracts/maths/number {};
  boolean = callPackage ./contracts/maths/boolean {};
};
components = rec {
  not = callPackage ./components/maths/boolean/not {};
  nand = callPackage ./components/maths/boolean/nand {};
  add = callPackage ./components/maths/number/add {};
};
in {
  inherit components contracts support;
  component-name = callPackage ./mappings/component-name.nix { inherit components; };
  contract-name = callPackage ./mappings/contract-name.nix { inherit contracts; };

}
