{ pkgs
  , lib ? pkgs.lib
  , debug
  , test
  , local-rustfbp
  , crates
  , edges
  , nodes}:
let
callPackage = pkgs.lib.callPackageWith (pkgs);
newpkgs = import (pkgs.fetchgit {
   url = https://github.com/NixOS/nixpkgs;
   rev = "1f811a67274e340d9e13987801fe726308e748ab";
   sha256 = "0dhmh0fcjki8qnvy1fyw4jhi0m3kvabj9nfcd2nc4dcl2ljc84mg";
 }) {};
rustc = newpkgs.rustcNightlyBin.rustc;
crates-support = rec {
  crates = crates;
  normalizeName = builtins.replaceStrings [ "-"] ["_"];
  depsStringCalc = pkgs.lib.fold ( dep: str: "${str} --extern ${normalizeName dep.name}=${dep}/lib${normalizeName dep.name}.rlib") "";
  cratesDeps = pkgs.lib.fold ( recursiveDeps : newCratesDeps: newCratesDeps ++ recursiveDeps.cratesDeps  );
  symlinkCalc = pkgs.lib.fold ( dep: str: "${str} ln -fs ${dep}/lib${normalizeName dep.name}.rlib mylibs/ \n") "mkdir mylibs\n ";
};
genName = callPackage ./genName.nix {};

in
rec {
  inherit crates-support;
  rustBinary = agent;
  agent = callPackage ./agent.nix {inherit debug test local-rustfbp crates-support rustc genName;};
  edge = callPackage ./edge.nix {inherit capnpc-rust genName;};
  subgraph = callPackage ./subgraph.nix {inherit genName;};
  capnpc-rust = callPackage ./capnpc-rust.nix {inherit crates rustBinary;};
}
