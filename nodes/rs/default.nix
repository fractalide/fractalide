{ buffet }:

# Please refer to section 2.6 namely Evolution of Public Contracts
# of the Collective Code Construction Contract in CONTRIBUTING.md
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.pkgs // buffet.support.node.rs // buffet.support // buffet.mods // buffet);
in
{
  # RAW NODES
  # -   raw nodes are incomplete and immature, they may wink into and out of existance
  # -   use at own risk, anything in this section can change at any time.

  app_todo_nodes = buffet.fractals.app_todo.nodes.rs;
  app_todo_model_test = buffet.fractals.app_todo_model.nodes.rs.test;
  app_todo_controller_test = buffet.fractals.app_todo_controller.nodes.rs.test;
  bench = callPackage ./bench {};
  bench_load = callPackage ./bench/load {};
  bench_inc_1000 = callPackage ./bench/inc_1000 {};
  bench_inc = callPackage ./bench/inc {};
  debug = callPackage ./debug {};
  example_wrangle = buffet.fractals.example_wrangle.nodes.rs.example_wrangle;
  nanomsg_nodes = buffet.fractals.nanomsg.nodes.rs;
  nanomsg_test = buffet.fractals.nanomsg.nodes.test;
  maths_boolean_and = callPackage ./maths/boolean/and {};
  maths_boolean_nand = callPackage ./maths/boolean/nand {};
  maths_boolean_not = callPackage ./maths/boolean/not {};
  maths_boolean_or = callPackage ./maths/boolean/or {};
  maths_boolean_print = callPackage ./maths/boolean/print {};
  maths_boolean_xor = callPackage ./maths/boolean/xor {};
  maths_boolean_true = callPackage ./maths/boolean/true {};
  maths_boolean_false = callPackage ./maths/boolean/false {};
  maths_number_add = callPackage ./maths/number/add {};
  net_http_nodes = buffet.fractals.net_http.nodes.rs;
  net_http_test = buffet.fractals.net_http.nodes.test;
  net_ndn = buffet.fractals.net_ndn.nodes.ndn;
  net_ndn_test = buffet.fractals.net_ndn.nodes.test;
  test_nand = callPackage ./test/nand {};
  test_not = callPackage ./test/not {};
  test_edges = callPackage ./test/edges {};
  ui_js_nodes = buffet.fractals.ui_js.nodes.rs;
  app_growtest = buffet.fractals.ui_js.nodes.rs.app_growtest;
  web_server = callPackage ./web/server {};
  workbench = buffet.fractals.workbench.nodes.rs.workbench;
  workbench_test = buffet.fractals.workbench.nodes.rs.test;

  # DRAFT NODES
  # -   draft nodes change a lot in tandom with other nodes in their subgraph
  # -   there will be change in these nodes and few people are using these nodes so expect breakage

  fs_list_dir = callPackage ./fs/list/dir {};
  fs_file_open = callPackage ./fs/file/open {};
  halter = callPackage ./halter {};
  io_print = callPackage ./io/print {};
  msg_action = callPackage ./msg/action {};
  msg_clone = callPackage ./msg/clone {};
  msg_delay = callPackage ./msg/delay {};
  msg_dispatcher = callPackage ./msg/dispatcher {};
  msg_replace = callPackage ./msg/replace {};


  # STABLE NODES
  # -   stable nodes do not change names of ports, agents nor subgraphs,
  # -   you may add new port names, but never change, nor remove port names

  # DEPRECATED NODES
  # -   deprecated nodes do not change names of ports, agents nor subgraphs.
  # -   keep the implementation functioning, print a warning message and tell users to use replacement node

  # LEGACY NODES
  # -   legacy nodes do not change names of ports, agents nor subgraphs.
  # -   assert and remove implementation of the node.
}
