{ pkgs, support }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
rec {
  maths-boolean-not = callPackage ./maths/boolean/not {};
  maths-boolean-nand = callPackage ./maths/boolean/nand {};
  maths-boolean-add = callPackage ./maths/number/add {};
}
