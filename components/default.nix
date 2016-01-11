{ pkgs, support }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
rec {
  maths_boolean_not = callPackage ./maths/boolean/not {};
  maths_boolean_nand = callPackage ./maths/boolean/nand {};
  maths_boolean_add = callPackage ./maths/number/add {};
}
