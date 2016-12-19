{ pkgs
  , lib ? pkgs.lib
  , debug
  , test
  , crates
  , edges
  , nodes}:
let
callPackage = pkgs.lib.callPackageWith (pkgs);
newpkgs = import (pkgs.fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "1f811a67274e340d9e13987801fe726308e748ab";
  sha256 = "0dhmh0fcjki8qnvy1fyw4jhi0m3kvabj9nfcd2nc4dcl2ljc84mg";
 }) {};
crates-support = rec {
  crates = crates;
  normalizeName = builtins.replaceStrings [ "-"] ["_"];
  depsStringCalc = pkgs.lib.fold ( dep: str: "${str} --extern ${normalizeName dep.name}=${dep}/lib${normalizeName dep.name}.rlib") "";
  cratesDeps = pkgs.lib.fold ( recursiveDeps : newCratesDeps: newCratesDeps ++ recursiveDeps.cratesDeps  );
  symlinkCalc = pkgs.lib.fold ( dep: str: "${str} ln -fs ${dep}/lib${normalizeName dep.name}.rlib nixcrates/ \n") "mkdir nixcrates\n ";
};
rustNightly = newpkgs.rustcNightlyBin.rustc;
genName = callPackage ./genName.nix {};
rustc = callPackage ./rustc.nix {inherit debug test crates-support rustNightly genName; };
crate = rustc { type = "crate"; };
executable = rustc { type = "executable"; };
capnpc-rust = callPackage ./capnpc-rust.nix { inherit executable crates; };
rustfbp = callPackage ./rustfbp.nix { inherit crate crates; cratesDeps = crates-support.cratesDeps; };
in
rec {
  inherit executable crates-support capnpc-rust rustfbp;
  agent = rustc { type = "agent"; };
  edge = callPackage ./edge.nix { inherit capnpc-rust genName; };
  subgraph = callPackage ./subgraph.nix { inherit genName; };
}
