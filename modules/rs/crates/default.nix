{ lib, buildPlatform, buildRustCrate, fetchgit, edgesModule }:

let crates = import ./crates.nix { inherit lib buildPlatform buildRustCrate fetchgit; }; in
crates // {
  rustfbp_0_3_34 = f: (crates.rustfbp_0_3_34 f).override (args: {
    preConfigure = "cp ${edgesModule.out}/edges.rs src";
  });
}
