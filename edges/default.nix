{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
in
# insert in alphabetical order in relevant section to reduce conflicts
# Schemas will undergo stability changes depending on any node (node-x) in any fractal becoming stable.
# It is the responsibility of that node-x's author to discuss with the author of the schema in question
# to stabilize the schema.
rec {
  # raw
  app_counter = callPackage ./app/counter {};
  app_todo_edges = buffet.fractals.app_todo.edges;
  domain_port = callPackage ./domain_port {};
  core_action = callPackage ./core/action {};
  core_action_add = callPackage ./core/action/add {};
  core_action_send = callPackage ./core/action/send {};
  core_action_connect = callPackage ./core/action/connect {};
  core_action_connect_sender = callPackage ./core/action/connect/sender {};
  core_graph = callPackage ./core/graph {};
  core_graph_edge = callPackage ./core/graph/edge {};
  core_graph_ext = callPackage ./core/graph/ext {};
  core_graph_imsg = callPackage ./core/graph/imsg {};
  core_graph_list_edge = callPackage ./core/graph/list/edge {};
  core_graph_list_ext = callPackage ./core/graph/list/ext {};
  core_graph_list_imsg = callPackage ./core/graph/list/imsg {};
  core_graph_list_node = callPackage ./core/graph/list/node {};
  core_graph_node = callPackage ./core/graph/node {};
  core_lexical = callPackage ./core/lexical {};
  core_semantic_error = callPackage ./core/semantic/error {};
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
  prim_list_text = callPackage ./prim/list/text {};
  kv_key_t_val_t = callPackage ./kv/key/t/val/t {};
  kv_key_t_val_i64 = callPackage ./kv/key/t/val/i64 {};
  kv_list_key_t_val_t = callPackage ./kv/list/key/t/val/t {};
  ntuple_tuple_tt = callPackage ./ntuple/tuple/tt {};
  ntuple_tuple_tb = callPackage ./ntuple/tuple/tb {};
  ntuple_triple_ttt = callPackage ./ntuple/triple/ttt {};
  ntuple_quadruple_u32u32u32f32 = callPackage ./ntuple/quadruple/u32u32u32f32 {};
  ntuple_list_tuple_tt = callPackage ./ntuple/list/tuple/tt {};
  ntuple_list_triple_ttt = callPackage ./ntuple/list/triple/ttt {};
  ntuple_list_tuple_tb = callPackage ./ntuple/list/tuple/tb {};
  fs_list_path = callPackage ./fs/list/path {};
  fs_path_option = callPackage ./fs/path/option {};
  fs_path = callPackage ./fs/path {};
  fs_file_desc = callPackage ./fs/file/desc {};
  fs_file_error = callPackage ./fs/file/error {};
  net_http_edges = buffet.fractals.net_http.edges;
  net_ndn_edges = buffet.fractals.net_ndn.edges;
  protocol_domain_port = callPackage ./protocol_domain_port {};
  url = callPackage ./url {};
  value_int64 = callPackage ./value/int64 {};
  value_string = callPackage ./value/string {};

  # draft

  # stable

  # deprecated

  # legacy
}
