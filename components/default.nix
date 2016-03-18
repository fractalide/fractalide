{ pkgs, support, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support // self);
# insert in alphabetical order to reduce conflicts
self = rec {
  accumulate_keyValues = callPackage ./accumulate/keyValues {};
  development_capnp_encode = callPackage ./development/capnp/encode {};
  development_fbp_errors = callPackage ./development/fbp/errors {};
  development_fbp_fvm = callPackage ./development/fbp/fvm {};
  development_fbp_parser_lexical = callPackage ./development/fbp/parser/lexical {};
  development_fbp_parser_print_graph = callPackage ./development/fbp/parser/print_graph {};
  development_fbp_parser_semantic = callPackage ./development/fbp/parser/semantic {};
  development_fbp_scheduler = callPackage ./development/fbp/scheduler {};
  development_test =callPackage ./development/test {};
  docs = callPackage ./docs {};
  drop_ip = callPackage ./drop/ip {};
  dt_vector_split_by_outarr_count = callPackage ./dt/vector/split/by/outarr/count {};
  dt_vector_extract_keyvalue = callPackage ./dt/vector/extract/keyvalue {};
  example_wrangle = callPackage ./example/wrangle {};
  example_wrangle_aggregate_triple = callPackage ./example/wrangle/aggregate_triple {};
  example_wrangle_anonymize = callPackage ./example/wrangle/anonymize {};
  example_wrangle_print = callPackage ./example/wrangle/print {};
  example_wrangle_processchunk = callPackage ./example/wrangle/processchunk {};
  example_wrangle_processchunk_aggregate_tuple = callPackage ./example/wrangle/processchunk/aggregate_tuple {};
  example_wrangle_processchunk_convert_json_vector = callPackage ./example/wrangle/processchunk/convert_json_vector {};
  example_wrangle_processchunk_iterate_paths = callPackage ./example/wrangle/processchunk/iterate_paths {};
  example_wrangle_stats = callPackage ./example/wrangle/stats {};
  fs_file_open = callPackage ./fs/file/open {};
  fs_file_print = callPackage ./fs/file/print {};
  fs_dir_list = callPackage ./fs/dir/list {};
  io_print = callPackage ./io/print {};
  ip_clone = callPackage ./ip/clone {};
  maths_boolean_and = callPackage ./maths/boolean/and {};
  maths_boolean_nand = callPackage ./maths/boolean/nand {};
  maths_boolean_not = callPackage ./maths/boolean/not {};
  maths_boolean_or = callPackage ./maths/boolean/or {};
  maths_boolean_xor = callPackage ./maths/boolean/xor {};
  maths_boolean_print = callPackage ./maths/boolean/print {};
  maths_number_add = callPackage ./maths/number/add {};
  net_ndn = callPackage ./net/ndn {};
  net_ndn_cs = callPackage ./net/ndn/cs {};
  net_ndn_faces = callPackage ./net/ndn/faces {};
  net_ndn_faces_wrap = callPackage ./net/ndn/faces/wrap {};
  net_ndn_faces_tcp = callPackage ./net/ndn/faces/tcp {};
  net_ndn_fib = callPackage ./net/ndn/fib {};
  net_ndn_pit = callPackage ./net/ndn/pit {};
  net_ndn_print_interest = callPackage ./net/ndn/print/interest {};
  net_socket_client = callPackage ./net/socket/client {};
  net_socket_server = callPackage ./net/socket/server {};
  print = callPackage ./print {};
  serialize_json_decode_extractKVfromVec = callPackage ./serialize/json/decode/extractKVfromVec {};
  test_dm = callPackage ./test/dm {};
  test_sjm = callPackage ./test/sjm {};
  ui_conrod_button = callPackage ./ui/conrod/button {};
  ui_conrod_window = callPackage ./ui/conrod/window {};
  ui_magic = callPackage ./ui/magic {};
  web_server = callPackage ./web/server {};
};
in
self
