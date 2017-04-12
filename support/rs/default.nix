{ pkgs
  , genName
  , unifySchema
  , buffet
}:
let
  callPackage = pkgs.lib.callPackageWith ( pkgs );
  cratesSupport = rec {
    crates = buffet.mods.rs;
    normalizeName = builtins.replaceStrings [ "-"] ["_"];
    depsStringCalc = pkgs.lib.fold ( dep: str: "${str} --extern ${normalizeName dep.name}=${dep}/lib${normalizeName dep.name}.rlib") "";
    cratesDeps = pkgs.lib.fold ( recursiveDeps : newCratesDeps: newCratesDeps ++ recursiveDeps.cratesDeps  );
    symlinkCalc = pkgs.lib.fold ( dep: str: "${str} ln -fs ${dep}/lib${normalizeName dep.name}.rlib nixcrates/ \n") "mkdir nixcrates\n ";
  };
  rustNightly = pkgs.rust.rustc;
  rustc = callPackage ./rustc.nix {inherit cratesSupport unifySchema rustNightly genName; };
in
{
  executable = rustc { type = "executable"; };
  crate = rustc { type = "crate"; };
  fvm = rustc { type = "fvm"; };
  agent = rustc { type = "agent"; };
}
