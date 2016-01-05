{ pkgs, support }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
rec {
  maths-number = callPackage ./maths/number {};
  maths-boolean = callPackage ./maths/boolean {};
}

