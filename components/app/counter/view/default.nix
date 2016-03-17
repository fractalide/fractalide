{ stdenv, buildFractalideSubnet, upkeepers
  , app_counter_viewer
  , ip_action
  , ip_dispatcher
  , ui_conrod_button
  , ui_conrod_lr
  , ui_conrod_position
  , ui_conrod_size
  , ui_conrod_text
  , ui_conrod_window
  , ...}:
  let
  doc = import ../../../doc {};
  in
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output

   'ui_button:(label="-", enable=true)' -> acc button(${ui_conrod_button})
   'ui_button:(label="+", enable=true)' -> acc button2(${ui_conrod_button})
   'generic_text:(text="0")' -> acc text(${ui_conrod_text})
   'generic_text:(text="create")~create' -> input button()
   'generic_text:(text="create")~create' -> input button2()
   'generic_text:(text="create")~create' -> input text()

   button() output[create] -> input button_size(${ui_conrod_size}) output ->
      places[1] lr(${ui_conrod_lr})
   'ui_size:(w = (padded = 50.0), h = (padded = 50.0))' -> option button_size()

   text() output -> input text_position(${ui_conrod_position}) output ->
      places[2] lr()
   'ui_position:(x = (none = void), y = (bottom = 100.0))' -> option text_position()

   button2() output[create] -> input button2_size(${ui_conrod_size}) output ->
               places[3] lr(${ui_conrod_lr})
   'ui_size:(w = (padded = 50.0), h = (padded = 50.0))' -> option button2_size()

   'ui_lr:(places=[])' -> acc lr()

   lr() output -> input window(${ui_conrod_window})


   in_dispatch() output[model] -> input viewer(${app_counter_viewer}) label -> input text()

   button() output[button_clicked] -> input minus(${ip_action}) output -> input out_dispatch()
   button2() output[button_clicked] -> input add(${ip_action}) output -> input out_dispatch()
   'generic_text:(text="minus")' -> option minus()
   'generic_text:(text="add")' -> option add()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
