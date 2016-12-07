{ pkgs
  , lib ? pkgs.lib
  , debug
  , test
  , local-rustfbp
  , edges
  , nodes}:
let
upkeepers = import ./upkeepers.nix;
callPackage = pkgs.lib.callPackageWith (pkgs);
cargo = pkgs.rustUnstable.cargo;
rustc = pkgs.rustUnstable.rustc;
in
rec {
  inherit upkeepers rustc cargo;
  rustRegistry = callPackage ./rust-packages.nix {};
  agent = callPackage ./buildFractalideComponent.nix {inherit debug test local-rustfbp rustRegistry rustc cargo genName;};
  edge = callPackage ./buildFractalideContract.nix {inherit capnpc-rust genName;};
  subgraph = callPackage ./buildFractalideSubnet.nix {inherit genName;};
  buildRustPackage = callPackage ./buildRustPackage.nix {inherit lib local-rustfbp debug test rustc rustRegistry;};
  genName = callPackage ./genName.nix {};
  capnpc-rust = callPackage ./capnpc-rust.nix {inherit rustRegistry rustc buildRustPackage;};
  encryptComponent = callPackage ./encryptComponent.nix {inherit pkgs debug;};
}
