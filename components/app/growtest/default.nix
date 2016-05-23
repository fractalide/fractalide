{ stdenv, buildFractalideSubnet, upkeepers
  , app_button_card
  , app_counter_card
  , ip_action
  , ip_delay
  , ui_js_block
  , ui_js_button
  , ui_js_growing_block
  , ui_js_page
  , development_fbp_subnet
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   td(${ui_js_block}) output -> input page(${ui_js_page})
   'js_block:(css="display: flex; flex-direction: column")' -> acc td()

   lr(${ui_js_block}) output -> places[1] td()
   'js_block:(css="display: flex;")' -> acc lr()

   button_add(${ui_js_button}) output -> places[1] lr()
   button_remove(${ui_js_button}) output -> places[2] lr()
   'js_button:(label="add")' -> acc button_add(${ui_js_button})
   'js_button:(label="remove")' -> acc button_remove(${ui_js_button})
   'generic_text:(text="")~create' -> input button_add()
   'generic_text:(text="")~create' -> input button_remove()


   gblock(${ui_js_growing_block}) output -> places[2] td()
   gblock() scheduler -> action sched(${development_fbp_subnet})
   sched() outputs[td] -> places[2] td()
   'generic_text:(text="${app_counter_card}")' -> option gblock()

   button_add() output[click] -> input minus(${ip_action}) output -> input gblock()
   button_remove() output[click] -> input add(${ip_action}) output -> input gblock()
   'generic_text:(text="add")' -> option minus()
   'generic_text:(text="remove")' -> option add()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
