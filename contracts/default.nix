{ pkgs, support, contracts, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // contracts // support);
in
# insert in alphabetical order to reduce conflicts
rec {
  app_counter = callPackage ./app/counter {};
  command = callPackage ./command {};
  domain_port = callPackage ./domain_port {};
  fbp_action = callPackage ./fbp/action {};
  fbp_graph = callPackage ./fbp/graph {};
  fbp_lexical = callPackage ./fbp/lexical {};
  fbp_semantic_error = callPackage ./fbp/semantic_error {};
  file_desc = callPackage ./file/desc {};
  file_error = callPackage ./file_error {};
  file_list = callPackage ./file/list {};
  generic_bool = callPackage ./generic/bool {};
  generic_i64 = callPackage ./generic/i64 {};
  generic_list_text = callPackage ./generic/list_text {};
  generic_text = callPackage ./generic/text {};
  generic_tuple_text = callPackage ./generic/tuple_text {};
  generic_u64 = callPackage ./generic/u64 {};
  js_create = callPackage ./js/create {};
  key_value = callPackage ./key/value {};
  list_tuple = callPackage ./list/tuple {};
  list_triple = callPackage ./list/triple {};
  list_text = callPackage ./list/text {};
  list_command = callPackage ./list/command {};
  maths_boolean = callPackage ./maths/boolean {};
  maths_number = callPackage ./maths/number {};
  net_http_address = callPackage ./net/http/address {};
  net_http_request = callPackage ./net/http/request {};
  net_http_response = callPackage ./net/http/response {};
  net_ndn_data = callPackage ./net/ndn/data {};
  net_ndn_interest = callPackage ./net/ndn/interest {};
  option_path = callPackage ./option_path {};
  path = callPackage ./path {};
  protocol_domain_port = callPackage ./protocol_domain_port {};
  quadruple = callPackage ./quadruple {};
  shell_commands = callPackage ./shell/commands {};
  tuple = callPackage ./tuple {};
  url = callPackage ./url {};
  value_int64 = callPackage ./value/int64 {};
  value_string = callPackage ./value/string {};
}
