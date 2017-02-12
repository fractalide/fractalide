
{ pkgs
  , genName
  , unifySchema
  , buffet
}:
let
  callPackage = pkgs.lib.callPackageWith ( pkgs );
  purspkgsSupport = rec {
    purspkgs = buffet.mods.purs;
    normalizeName = builtins.replaceStrings [ "-"] ["_"];
    depsStringCalc = pkgs.lib.fold ( dep: str: "${str} --extern ${normalizeName dep.name}=${dep}/lib${normalizeName dep.name}.rlib") "";
    cratesDeps = pkgs.lib.fold ( recursiveDeps : newCratesDeps: newCratesDeps ++ recursiveDeps.cratesDeps  );
    symlinkCalc = pkgs.lib.fold ( dep: str: "${str} ln -fs ${dep}/lib${normalizeName dep.name}.rlib nixcrates/ \n") "mkdir nixcrates\n ";
  };
  purescript = pkgs.haskellPackages.purescript_0_10_5;
  psc = callPackage ./psc.nix {inherit purspkgsSupport unifySchema purescript genName; };
in
{
  executable = psc { type = "executable"; };
  crate = psc { type = "crate"; };
  fvm = psc { type = "fvm"; };
  agent = psc { type = "agent"; };
}
