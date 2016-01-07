{ pkgs, support }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
# insert in alphabetical order to prevent conflicts
rec {
  maths_boolean_nand = callPackage ./maths/boolean/nand {};
  maths_boolean_not = callPackage ./maths/boolean/not {};
  maths_number_add = callPackage ./maths/number/add {};
  file_print = callPackage ./file/print {};
}
