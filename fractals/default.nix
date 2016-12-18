{ buffet }:

rec {
  example_wrangle = import ./example/wrangle { inherit buffet; };
  app_todo = import ./app/todo { inherit buffet; };
  app_todo_controller = import ./app/todo/controller { inherit buffet; };
  app_todo_model = import ./app/todo/model { inherit buffet; };
  nanomsg = import ./nanomsg { inherit buffet; };
  net_http = import ./net/http { inherit buffet; };
  net_ndn = import ./net/ndn { inherit buffet; };
  ui_js = import ./ui/js { inherit buffet; };
  workbench = import ./workbench { inherit buffet; };
}
