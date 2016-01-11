{ pkgs, support }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
rec {
  maths_number = callPackage ./maths/number {};
  maths_boolean = callPackage ./maths/boolean {};
}

