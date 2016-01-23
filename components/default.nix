{ pkgs, support, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
# insert in alphabetical order to reduce conflicts
rec {
  development_fvm = callPackage ./development/fvm {};
  development_parser_fbp_lexical = callPackage ./development/parser/fbp/lexical {};
  development_parser_fbp_print_graph = callPackage ./development/parser/fbp/print_graph {};
  development_parser_fbp_semantic = callPackage ./development/parser/fbp/semantic {};
  file_open = callPackage ./file/open {};
  file_print = callPackage ./file/print {};
  maths_boolean_and = callPackage ./maths/boolean/and {};
  maths_boolean_nand = callPackage ./maths/boolean/nand {};
  maths_boolean_not = callPackage ./maths/boolean/not {};
  maths_boolean_or = callPackage ./maths/boolean/or {};
  maths_number_add = callPackage ./maths/number/add {};
}
