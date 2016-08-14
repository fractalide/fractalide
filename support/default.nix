{ pkgs, lib ? pkgs.lib, debug, local-rustfbp, contracts, components}:
let
upkeepers = import ./upkeepers.nix;
callPackage = pkgs.lib.callPackageWith (pkgs);
cargo = pkgs.rustUnstable.cargo;
rustc = pkgs.rustUnstable.rustc;
in
rec {
  inherit upkeepers rustc cargo;
  rustRegistry = callPackage ./rust-packages.nix {};
  buildFractalideComponent = callPackage ./buildFractalideComponent.nix {inherit debug local-rustfbp capnpc-rust rustRegistry rustc cargo;};
  buildFractalideContract = callPackage ./buildFractalideContract.nix {inherit capnpc-rust genName;};
  buildFractalideSubnet = callPackage ./buildFractalideSubnet.nix {inherit genName;};
  buildRustPackage = callPackage ./buildRustPackage.nix {inherit lib local-rustfbp debug rustc rustRegistry;};
  genName = callPackage ./genName.nix {};
  capnpc-rust = callPackage ./capnpc-rust.nix {inherit rustRegistry rustc buildRustPackage;};
  contract_lookup = callPackage ./contract_lookup { inherit buildFractalideComponent upkeepers; all_contracts = contracts;};
}
