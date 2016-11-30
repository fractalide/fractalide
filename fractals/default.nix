{ buffet }:
let
callPackage = buffet.pkgs.lib.callPackageWith ( buffet );
# insert in alphabetical order to reduce conflicts
self = rec {
  example_wrangle = callPackage ./example/wrangle {};
  app_todo = callPackage ./app/todo {};
  app_todo_controller = callPackage ./app/todo/controller {};
  app_todo_model = callPackage ./app/todo/model {};
  nanomsg = callPackage ./nanomsg {};
  net_http = callPackage ./net/http {};
  net_ndn = callPackage ./net/ndn {};
  ui_js = callPackage ./ui/js {};
  workbench = callPackage ./workbench {};
};
in
self
