{ pkgs, lib ? pkgs.lib, buildType, rustfbpPath, contracts}:
let
callPackage = pkgs.lib.callPackageWith (pkgs);
in
rec {
  cargo = pkgs.cargo;
  rustcMaster = pkgs.rustcMaster;
  rustRegistry = callPackage ./rust-packages.nix {};
  buildFractalideComponent = callPackage ./buildFractalideComponent.nix {inherit lib buildType rustfbpPath capnpc-rust rustRegistry;};
  buildFractalideContract = callPackage ./buildFractalideContract.nix {inherit capnpc-rust genName;};
  buildFractalideSubnet = callPackage ./buildFractalideSubnet.nix {inherit genName;};
  buildRustPackage = callPackage ./buildRustPackage.nix {inherit rustRegistry;};
  genName = callPackage ./genName.nix {};
  capnpc-rust = callPackage ./capnpc-rust.nix {inherit rustRegistry buildRustPackage;};
  filterContracts = List: map (name: (builtins.head (builtins.head (lib.attrValues (lib.filterAttrs (n: v: n == name) contracts))))) List;
}
