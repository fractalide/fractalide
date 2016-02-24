{ stdenv, buildFractalideSubnet, upkeepers
  , maths_boolean_not
  , maths_boolean_print
  , ui_conrod_button
  , ui_conrod_window
  , print
  , freetype
  , SDL2
  , mesa
  , xlibs
  , ...}:

buildFractalideSubnet rec {
 
 src = ./.;

  buildInputs = [ freetype SDL2 ];
  LD_LIBRARY_PATH = with xlibs; "${mesa}/lib:${libX11}/lib:${libXcursor}/lib:${libXxf86vm}/lib:${libXi}/lib:${SDL2}/lib";
  
  subnet = ''
'maths_boolean:(boolean=true)' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})

button(${ui_conrod_button}) output -> input print(${print})
'generic_text:(text="Receive at output")' -> option print()

button() output[button_clicked] -> input print_clicked(${print})
'generic_text:(text="A button is clicked")' -> option print_clicked()

'maths_boolean:(boolean=true)' -> input window(${ui_conrod_window})
  '';

  meta = with stdenv.lib; {
    description = "Subnet: development testing file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
