{ pkgs, support }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
# insert in alphabetical order to prevent conflicts
rec {
  maths_boolean = callPackage ./maths/boolean {};
  maths_number = callPackage ./maths/number {};
  file = callPackage ./file {};
  file_error = callPackage ./file_error {};
  path = callPackage ./path {};
  fbp_lexical = callPackage ./fbp/lexical {};
  fbp_graph = callPackage ./fbp/graph {};
  fbp_semantic_error = callPackage ./fbp/semantic_error {};
}

