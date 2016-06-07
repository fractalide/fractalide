{ stdenv, buildFractalideSubnet, upkeepers
  , ui_js_edit_keyfilter
  , ui_js_edit_validate
  , ui_js_edit_viewer
  , io_print
  , ip_action
  , ip_clone
  , ip_dispatcher
  , ui_js_input
  , ui_js_placeholder
  , ui_js_text
  , debug
  , ...}:
  let
  doc = import ../../../doc {};
  in
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output

   ph(${ui_js_placeholder}) output -> input out_dispatch()
   'js_placeholder:()' -> acc ph()

   'js_text:(label="this is a test")' -> acc text(${ui_js_text})
   text() output -> places[1] ph()

   'js_input:(label="this is a test")' -> acc input(${ui_js_input})
   input() output -> places[2] ph()

   text() output[dblclick] -> input disp_input(${ip_action}) output -> input input()
   'generic_text:(text="display")' -> option disp_input()

   input() output[keyup] -> input key_filter(${ui_js_edit_keyfilter})
   key_filter() validate -> input input()
   key_filter() escape -> input out_dispatch()
   key_filter() display -> input text()

   input() output[focusout] -> input validate(${ui_js_edit_validate})
   validate() validate -> input input()
   validate() display -> input text()

   in_dispatch() output[model] -> input viewer(${ui_js_edit_viewer}) label -> input clone(${ip_clone})
   clone() clone[1] -> input text()
   clone() clone[2] -> input input()

   in_dispatch() output[create] -> input create_clone(${ip_clone})
   in_dispatch() output[delete] -> input clone()
   create_clone() clone[1] -> input text()
   create_clone() clone[2] -> input input()
   create_clone() clone[3] -> input disp(${ip_action}) output -> input text()
   'generic_text:(text="display")' -> option disp()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
