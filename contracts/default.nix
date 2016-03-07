{ pkgs, support, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support);
in
# insert in alphabetical order to reduce conflicts
rec {
  domain_port = callPackage ./domain_port {};
  fbp_graph = callPackage ./fbp/graph {};
  fbp_lexical = callPackage ./fbp/lexical {};
  fbp_semantic_error = callPackage ./fbp/semantic_error {};
  file_desc = callPackage ./file/desc {};
  file_error = callPackage ./file_error {};
  file_list = callPackage ./file/list {};
  generic_list_text = callPackage ./generic/list_text {};
  generic_text = callPackage ./generic/text {};
  generic_u64 = callPackage ./generic/u64 {};
  key_value = callPackage ./key/value {};
  list_tuple = callPackage ./list/tuple {};
  list_triple = callPackage ./list/triple {};
  maths_boolean = callPackage ./maths/boolean {};
  maths_number = callPackage ./maths/number {};
  net_ndn_data = callPackage ./net/ndn/data {};
  net_ndn_interest = callPackage ./net/ndn/interest {};
  option_path = callPackage ./option_path {};
  path = callPackage ./path {};
  protocol_domain_port = callPackage ./protocol_domain_port {};
  quadruple = callPackage ./quadruple {};
  ui_conrod = callPackage ./ui/conrod {};
  url = callPackage ./url {};
  value_int64 = callPackage ./value/int64 {};
  value_string = callPackage ./value/string {};
}

