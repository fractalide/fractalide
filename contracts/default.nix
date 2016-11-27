{ support, contracts, fractals }:
let
  contract = support.contract;
in
# insert in alphabetical order to reduce conflicts
rec {
  app_counter = import ./app/counter { inherit contract contracts; };
  app_todo_contracts = fractals.app_todo.contracts;
  command = import ./command { inherit contract contracts; };
  domain_port = import ./domain_port { inherit contract contracts; };
  fbp_action = import ./fbp/action { inherit contract contracts; };
  fbp_graph = import ./fbp/graph { inherit contract contracts; };
  fbp_lexical = import ./fbp/lexical { inherit contract contracts; };
  fbp_semantic_error = import ./fbp/semantic_error { inherit contract contracts; };
  file_desc = import ./file/desc { inherit contract contracts; };
  file_error = import ./file_error { inherit contract contracts; };
  file_list = import ./file/list { inherit contract contracts; };
  generic_bool = import ./generic/bool { inherit contract contracts; };
  generic_i64 = import ./generic/i64 { inherit contract contracts; };
  generic_list_text = import ./generic/list_text { inherit contract contracts; };
  generic_text = import ./generic/text { inherit contract contracts; };
  generic_tuple_text = import ./generic/tuple_text { inherit contract contracts; };
  generic_u64 = import ./generic/u64 { inherit contract contracts; };
  js_create = import ./js/create { inherit contract contracts; };
  key_value = import ./key/value { inherit contract contracts; };
  list_tuple = import ./list/tuple { inherit contract contracts; };
  list_triple = import ./list/triple { inherit contract contracts; };
  list_text = import ./list/text { inherit contract contracts; };
  list_command = import ./list/command { inherit contract contracts; };
  maths_boolean = import ./maths/boolean { inherit contract contracts; };
  maths_number = import ./maths/number { inherit contract contracts; };
  net_http_contracts = fractals.net_http.contracts;
  net_ndn_contracts = fractals.net_ndn.contracts;
  option_path = import ./option_path { inherit contract contracts; };
  path = import ./path { inherit contract contracts; };
  protocol_domain_port = import ./protocol_domain_port { inherit contract contracts; };
  quadruple = import ./quadruple { inherit contract contracts; };
  shell_commands = import ./shell/commands { inherit contract contracts; };
  tuple = import ./tuple { inherit contract contracts; };
  url = import ./url { inherit contract contracts; };
  value_int64 = import ./value/int64 { inherit contract contracts; };
  value_string = import ./value/string { inherit contract contracts; };
}
