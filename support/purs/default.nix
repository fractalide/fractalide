{ pkgs
  , genName
  , unifySchema
  , buffet
}:
let
  callPackage = pkgs.lib.callPackageWith ( pkgs );
  purspkgsSupport = rec {
    purspkgs = buffet.mods.purs;
    pureDeps = pkgs.lib.fold ( recursiveDeps : newPuresDeps: newPuresDeps ++ recursiveDeps.pureDeps  );
    symlinkCalc = pkgs.lib.fold ( dep: str: "${str} ln -fs ${dep} purelibs/ \n") "mkdir purelibs\n ";
  };
  purescript = pkgs.haskellPackages.purescript_0_10_5;
  psc = callPackage ./psc.nix {inherit purspkgsSupport unifySchema purescript genName; };
in
{
  agent = psc { type = "agent"; };
}
