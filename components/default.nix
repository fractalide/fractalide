{ pkgs, support, contracts, fractals, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support // contracts // self);
# insert in alphabetical order to reduce conflicts
self = rec { # use one line only to insert a component (utils/new_component.py sorts this list)
  app_counter_add = callPackage ./app/counter/add {};
  app_counter_card = callPackage ./app/counter/card {};
  app_counter_counter = callPackage ./app/counter/counter {};
  app_counter_create = callPackage ./app/counter/create {};
  app_counter_delta = callPackage ./app/counter/delta {};
  app_counter_minus = callPackage ./app/counter/minus {};
  app_counter_view = callPackage ./app/counter/view {};
  app_counter_viewer = callPackage ./app/counter/viewer {};
  app_growtest = callPackage ./app/growtest {};
  app_model = callPackage ./app/model {};
  app_test = callPackage ./app/test {};
  debug = callPackage ./debug {};
  docs = callPackage ./docs {};
  drop_ip = callPackage ./drop/ip {};
  dt_vector_split_by_outarr_count = callPackage ./dt/vector/split/by/outarr/count {};
  example_wrangle = fractals.example_wrangle.components.example_wrangle;
  fs_dir_list = callPackage ./fs/dir/list {};
  fs_file_open = callPackage ./fs/file/open {};
  lain = callPackage ./shells/lain {}; # special name for the main build product
  halter = callPackage ./halter {};
  io_print = callPackage ./io/print {};
  io_print_list_text = callPackage ./io/print/list/text {};
  ip_action = callPackage ./ip/action {};
  ip_clone = callPackage ./ip/clone {};
  ip_delay = callPackage ./ip/delay {};
  ip_dispatcher = callPackage ./ip/dispatcher {};
  ip_replace = callPackage ./ip/replace {};
  maths_boolean_and = callPackage ./maths/boolean/and {};
  maths_boolean_nand = callPackage ./maths/boolean/nand {};
  maths_boolean_not = callPackage ./maths/boolean/not {};
  maths_boolean_or = callPackage ./maths/boolean/or {};
  maths_boolean_print = callPackage ./maths/boolean/print {};
  maths_boolean_xor = callPackage ./maths/boolean/xor {};
  maths_number_add = callPackage ./maths/number/add {};
  net_http_components = fractals.net_http.components;
  net_ndn = callPackage ./net/ndn {inherit pkgs support contracts; components = self;};
  nucleus_capnp_encode = callPackage ./nucleus/capnp/encode {};
  nucleus_find_component = callPackage ./nucleus/find/component {};
  nucleus_find_contract = callPackage ./nucleus/find/contract {};
  nucleus_flow_errors = callPackage ./nucleus/flow/errors {};
  nucleus_flow_parser_graph_check = callPackage ./nucleus/flow/parser/graph/check {};
  nucleus_flow_parser_graph_print = callPackage ./nucleus/flow/parser/graph/print {};
  nucleus_flow_parser_lexical = callPackage ./nucleus/flow/parser/lexical {};
  nucleus_flow_parser_semantic = callPackage ./nucleus/flow/parser/semantic {};
  nucleus_flow_scheduler = callPackage ./nucleus/flow/scheduler {};
  nucleus_flow_subnet = callPackage ./nucleus/flow/subnet {};
  nucleus_flow_vm = callPackage ./nucleus/flow/vm {};
  print_file_with_feedback = callPackage ./print/file/with/feedback {};
  print_with_feedback = callPackage ./print/with/feedback {};
  shells_lain_commands = callPackage ./shells/lain/commands {};
  shells_lain_commands_print = callPackage ./shells/lain/commands/print {};
  shells_lain_commands_dirname = callPackage ./shells/lain/commands/dirname {};
  shells_lain_flow = callPackage ./shells/lain/flow {};
  shells_lain_parse = callPackage ./shells/lain/parse {};
  shells_lain_prompt = callPackage ./shells/lain/prompt {};
  test_dm = callPackage ./test/dm {};
  test_sjm = callPackage ./test/sjm {};
  ui_js = callPackage ./ui/js {inherit pkgs support contracts; components = self;};
  web_server = callPackage ./web/server {};
  workbench = fractals.workbench.components.workbench;
  workbench_encrypt = fractals.workbench.components.workbench_encrypt;
}; # use one line only to insert a component (utils/new_component.py sorts this list)
in
self
