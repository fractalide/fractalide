{ pkgs, lib ? pkgs.lib, debug, contracts, components}:
let
upkeepers = import ./upkeepers.nix;
callPackage = pkgs.lib.callPackageWith (pkgs);
in
rec {
  inherit upkeepers;
  cargo = pkgs.cargo;
  rustcMaster = pkgs.rustcMaster;
  rustRegistry = callPackage ./rust-packages.nix {};
  buildFractalideComponent = callPackage ./buildFractalideComponent.nix {inherit debug capnpc-rust rustRegistry;};
  buildFractalideContract = callPackage ./buildFractalideContract.nix {inherit capnpc-rust genName;};
  buildFractalideSubnet = callPackage ./buildFractalideSubnet.nix {inherit genName;};
  buildRustPackage = callPackage ./buildRustPackage.nix {inherit lib debug rustRegistry;};
  genName = callPackage ./genName.nix {};
  capnpc-rust = callPackage ./capnpc-rust.nix {inherit rustRegistry buildRustPackage;};
  filterContracts = List: map (name: (lib.attrValues (lib.filterAttrs (n: v: n == name) contracts))) List;
  component_lookup = callPackage ./component-lookup { inherit components buildFractalideComponent filterContracts upkeepers; };
  contract_lookup = callPackage ./contract-lookup { inherit contracts buildFractalideComponent filterContracts upkeepers; };
}
