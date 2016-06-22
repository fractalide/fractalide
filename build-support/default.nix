{ pkgs, lib ? pkgs.lib, debug, contracts, components}:
let
upkeepers = import ./upkeepers.nix;
callPackage = pkgs.lib.callPackageWith (pkgs);
cargo = pkgs.rustBeta.cargo;
rustc = pkgs.rustBeta.rustc;
in
rec {
  inherit upkeepers rustc cargo;
  rustRegistry = callPackage ./rust-packages.nix {};
  apk-builder = callPackage ./apk-builder.nix{inherit rustRegistry buildRustPackage;};
  ndk-standalone-toolchain = callPackage ./ndk-standalone-toolchain.nix {};
  ncurses_32bit = callPackage ./pkgs/ncurses.nix {};
  zlib_32bit = callPackage ./pkgs/zlib.nix {};
  rust-android = callPackage ./rust-android.nix {inherit rustc ndk-standalone-toolchain ncurses_32bit zlib_32bit;};
  buildFractalideComponent = callPackage ./buildFractalideComponent.nix {inherit debug capnpc-rust rustRegistry rustc cargo;};
  buildFractalideContract = callPackage ./buildFractalideContract.nix {inherit capnpc-rust genName;};
  buildRustPackage = callPackage ./buildRustPackage.nix {inherit lib debug rustc rustRegistry;};
  genName = callPackage ./genName.nix {};
  capnpc-rust = callPackage ./capnpc-rust.nix {inherit rustRegistry rustc buildRustPackage;};
  contract_lookup = callPackage ./contract_lookup { inherit contracts buildFractalideComponent filterContracts upkeepers; };
  filterContracts = List: map (name: (lib.attrValues (lib.filterAttrs (n: v: n == name) contracts))) List;
  buildFractalideSubnet = callPackage ./buildFractalideSubnet.nix {inherit genName;};
}
