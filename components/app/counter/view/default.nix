{ stdenv, buildFractalideSubnet, upkeepers
  , app_counter_viewer
  , io_print
  , ip_action
  , ip_clone
  , ip_dispatcher
  , ui_js_input
  , ui_js_block
  , ui_js_button
  , ui_js_text
  , ...}:
  let
  doc = import ../../../doc {};
  in
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output

   td(${ui_js_block}) output -> input out_dispatch()
   'js_block:(css="display: flex; flex-direction: column")' -> acc td()

   lr(${ui_js_block}) output -> places[0] td()
   'js_block:(css="display: flex;")' -> acc lr()

   'js_button:(label="-")' -> acc button(${ui_js_button})
   'js_button:(label="+")' -> acc button2(${ui_js_button})
   'js_text:(label="0", css="margin:0 10px;")' -> acc text(${ui_js_text})


   button() output -> places[0] lr()
   button2() output -> places[2] lr()
   text() output -> places[1] lr()

   in_dispatch() output[model] -> input viewer(${app_counter_viewer}) label -> input text()

   button() output[click] -> input minus(${ip_action}) output -> input out_dispatch()
   button2() output[click] -> input add(${ip_action}) output -> input out_dispatch()
   'generic_text:(text="minus")' -> option minus()
   'generic_text:(text="add")' -> option add()


   input(${ui_js_input}) output -> places[1] td()
   'js_input:(label="1")' -> acc input()

   input() output[input] -> input delta(${ip_action}) output -> input out_dispatch()
   'generic_text:(text="delta")' -> option delta()

   viewer() delta -> input input()

   in_dispatch() output[create] -> input create_clone(${ip_clone})
   in_dispatch() output[delete] -> input create_clone()
   create_clone() clone[1] -> input button()
   create_clone() clone[2] -> input button2()
   create_clone() clone[3] -> input text()
   create_clone() clone[4] -> input input()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
