{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
in
# insert in alphabetical order in relevant section to reduce conflicts
# Schemas will undergo stability changes depending on any node (node-x) in any fractal becoming stable.
# It is the responsibility of that node-x's author to discuss with the author of the schema in question
# to stabilize the schema.
rec {
  # experimental
  app_counter = callPackage ./app/counter {};
  app_todo_edges = buffet.fractals.app_todo.edges;
  command = callPackage ./command {};
  domain_port = callPackage ./domain_port {};
  fbp_action = callPackage ./fbp/action {};
  fbp_graph = callPackage ./fbp/graph {};
  fbp_lexical = callPackage ./fbp/lexical {};
  fbp_semantic_error = callPackage ./fbp/semantic_error {};
  file_desc = callPackage ./file/desc {};
  file_error = callPackage ./file_error {};
  file_list = callPackage ./file/list {};
  prim_bool = callPackage ./prim/bool {};
  prim_i8 = callPackage ./prim/i8 {};
  prim_i16 = callPackage ./prim/i16 {};
  prim_i32 = callPackage ./prim/i32 {};
  prim_i64 = callPackage ./prim/i64 {};
  prim_u8 = callPackage ./prim/u8 {};
  prim_u16 = callPackage ./prim/u16 {};
  prim_u32 = callPackage ./prim/u32 {};
  prim_u64 = callPackage ./prim/u64 {};
  prim_f32 = callPackage ./prim/f32 {};
  prim_f64 = callPackage ./prim/f64 {};
  prim_text = callPackage ./prim/text {};
  prim_data = callPackage ./prim/data {};
  prim_void = callPackage ./prim/void {};
  key_t_val_t = callPackage ./key/t/val/t {};
  key_t_val_i64 = callPackage ./key/t/val/i64 {};
  list_text = callPackage ./list/text {};
  list_command = callPackage ./list/command {};
  maths_boolean = callPackage ./maths/boolean {};
  maths_number = callPackage ./maths/number {};
  net_http_edges = buffet.fractals.net_http.edges;
  net_ndn_edges = buffet.fractals.net_ndn.edges;
  option_path = callPackage ./option_path {};
  path = callPackage ./path {};
  protocol_domain_port = callPackage ./protocol_domain_port {};
  shell_commands = callPackage ./shell/commands {};
  ntuple_tuple_tt = callPackage ./ntuple/tuple/tt {};
  ntuple_tuple_tb = callPackage ./ntuple/tuple/tb {};
  list_ntuple_tuple_tb = callPackage ./list/ntuple/tuple/tb {};
  ntuple_triple_ttt = callPackage ./ntuple/triple/ttt {};
  list_ntuple_tuple_tt = callPackage ./list/ntuple/tuple/tt {};
  list_key_t_val_t = callPackage ./list/key/t/val/t {};
  list_ntuple_triple_ttt = callPackage ./list/ntuple/triple/ttt {};
  ntuple_quadruple_u32u32u32f32 = callPackage ./ntuple/quadruple/u32u32u32f32 {};
  url = callPackage ./url {};
  value_int64 = callPackage ./value/int64 {};
  value_string = callPackage ./value/string {};
  # stable

  # deprecated

  # legacy
}
