{ stdenv, buildFractalideSubnet, upkeepers
  , maths_boolean_not
  , maths_boolean_print
  , maths_boolean_nand
  , ui_conrod_button
  , ui_conrod_lr
  , ui_conrod_position
  , ui_conrod_size
  , ui_conrod_text
  , ui_conrod_window
  , print
  , web_server
  , io_print
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   'maths_boolean:(boolean=false)' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})
   'maths_boolean:(boolean=false)' -> a nand(${maths_boolean_nand}) output -> input disp(${maths_boolean_print})
   'maths_boolean:(boolean=false)' -> b nand()

   'ui_button:(label="first", enable=true)' -> acc button(${ui_conrod_button})
   'ui_button:(label="second", enable=false)' -> acc button2(${ui_conrod_button})
   'generic_text:(text="0")' -> acc text(${ui_conrod_text})
   'generic_text:(text="create")~create' -> input button()
   'generic_text:(text="create")~create' -> input button2()
   'generic_text:(text="create")~create' -> input text()

   button() output[create] -> input button_size(${ui_conrod_size}) output ->
      input button_position(${ui_conrod_position}) output ->
      places[1] lr(${ui_conrod_lr})
   'ui_size:(w = (fixed = 80.0), h = (padded = 100.0))' -> option button_size()
   'ui_position:(x = (right = 10.0), y = (none = void))' -> option button_position()

   text() output -> places[2] lr()
   button2() output -> places[3] lr()

   'ui_lr:(places=[])' -> acc lr()

   lr() output -> input window(/home/denis/.fractalide/store/ui_conrod_window/)

   button() output[button_clicked] -> input print_clicked(${print})
   'generic_text:(text="A button is clicked")' -> option print_clicked()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: development testing file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
