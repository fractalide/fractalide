{ stdenv, buildFractalideSubnet, upkeepers
  , ui_js_edit_create
  , ui_js_edit_keyfilter
  , ui_js_edit_validate
  , ui_js_edit_viewer
  , io_print
  , ip_action
  , ip_clone
  , ip_dispatcher
  , ui_js_placeholder
  , ui_js_tag
  , debug
  # contracts
  , generic_text
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output

   ph(${ui_js_placeholder}) output -> input out_dispatch()

   text(${ui_js_tag}) output -> places[1] ph()
   input(${ui_js_tag}) output -> places[2] ph()

   text() output[dblclick] -> input disp_input(${ip_action}) output -> input input()
   '${generic_text}:(text="display")' -> option disp_input()

   input() output[keyup] -> input key_filter(${ui_js_edit_keyfilter})
   key_filter() validate -> input input()
   key_filter() escape -> input out_dispatch()
   key_filter() display -> input text()

   input() output[focusout] -> input validate(${ui_js_edit_validate})
   validate() validate -> input input()
   validate() display -> input text()

   in_dispatch() output[model] -> input viewer(${ui_js_edit_viewer})
   in_dispatch() output[escape] -> input viewer()
   viewer() text -> input text()
   viewer() input -> input input()

   in_dispatch() output[create] -> input create(${ui_js_edit_create})
   create() ph -> input ph()
   create() text -> input text()
   create() input -> input input()

   in_dispatch() output[delete] -> input clone(${ip_clone})
   clone() clone[1] -> input text()
   clone() clone[2] -> input input()
   clone() clone[3] -> input ph()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
