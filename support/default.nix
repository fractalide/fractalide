{ pkgs
  , lib ? pkgs.lib
  , debug
  , test
  , crates
  , edges
  , nodes}:
let
callPackage = pkgs.lib.callPackageWith (pkgs);
crates-support = rec {
  crates = crates;
  normalizeName = builtins.replaceStrings [ "-"] ["_"];
  depsStringCalc = pkgs.lib.fold ( dep: str: "${str} --extern ${normalizeName dep.name}=${dep}/lib${normalizeName dep.name}.rlib") "";
  cratesDeps = pkgs.lib.fold ( recursiveDeps : newCratesDeps: newCratesDeps ++ recursiveDeps.cratesDeps  );
  symlinkCalc = pkgs.lib.fold ( dep: str: "${str} ln -fs ${dep}/lib${normalizeName dep.name}.rlib nixcrates/ \n") "mkdir nixcrates\n ";
};
rustNightly = pkgs.rustNightlyBin.rustc;
genName = callPackage ./genName.nix {};
rustc = callPackage ./rustc.nix {inherit debug test crates-support capnpc-rust rustNightly genName; };
crate = rustc { type = "crate"; };
executable = rustc { type = "executable"; };
capnpc-rust = callPackage ./capnpc-rust.nix { inherit executable crates; };
rustfbp = callPackage ./rustfbp.nix { inherit crate crates; };
in
rec {
  inherit executable crates-support capnpc-rust rustfbp;
  agent = rustc { type = "agent"; };
  edge = callPackage ./edge.nix { inherit capnpc-rust genName; };
  subgraph = callPackage ./subgraph.nix { inherit genName; };
}
