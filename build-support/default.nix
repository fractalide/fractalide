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
  apk-builder = callPackage ./apk-builder.nix{inherit rustRegistry buildRustPackage;};
  ndk-standalone-toolchain = callPackage ./ndk-standalone-toolchain.nix {};
  buildFractalideComponent = callPackage ./buildFractalideComponent.nix {inherit debug capnpc-rust rustRegistry;};
  buildFractalideContract = callPackage ./buildFractalideContract.nix {inherit capnpc-rust genName;};
  buildFractalideSubnet = callPackage ./buildFractalideSubnet.nix {inherit genName filterDeps extractDepsFromSubnet;};
  buildRustPackage = callPackage ./buildRustPackage.nix {inherit lib debug rustRegistry;};
  genName = callPackage ./genName.nix {};
  capnpc-rust = callPackage ./capnpc-rust.nix {inherit rustRegistry buildRustPackage;};
  component_lookup = callPackage ./component_lookup { inherit components buildFractalideComponent filterContracts contract_lookup upkeepers; };
  contract_lookup = callPackage ./contract_lookup { inherit contracts buildFractalideComponent filterContracts upkeepers; };
  filterContracts = List: map (name: (lib.attrValues (lib.filterAttrs (n: v: n == name) contracts))) List;
  filterDeps = List: map (name: (lib.attrValues (lib.filterAttrs (n: v: n == name) components))) List;
  listifyContents = fileContents:(lib.splitString "|" (builtins.replaceStrings ["(" ")" " "] ["|" "|" ""] fileContents));
  extractDepsFromSubnet = subnetPath: (listifyContents (builtins.readFile subnetPath));
}
