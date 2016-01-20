{ pkgs, support, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
# insert in alphabetical order to reduce conflicts
rec {
  fbp_fvm_option = callPackage ./fbp/fvm_option {};
  fbp_graph = callPackage ./fbp/graph {};
  fbp_lexical = callPackage ./fbp/lexical {};
  fbp_semantic_error = callPackage ./fbp/semantic_error {};
  file = callPackage ./file {};
  file_error = callPackage ./file_error {};
  generic_list_text = callPackage ./generic/list_text {};
  generic_text = callPackage ./generic/text {};
  maths_boolean = callPackage ./maths/boolean {};
  maths_number = callPackage ./maths/number {};
  path = callPackage ./path {};
}

