{ stdenv, buildFractalideSubnet, upkeepers
  , maths_boolean_not
  , maths_boolean_print
  , maths_boolean_nand
  , ui_conrod_button
  , ui_conrod_window
  , print
  , web_server
  , io_print
  , ui_magic
  , freetype
  , SDL2
  , mesa
  , xlibs
  , ...}:
  let
  doc = import ../../../doc {};
  in
  buildFractalideSubnet rec {

   src = ./.;

   buildInputs = [ freetype SDL2 ];
   LD_LIBRARY_PATH = with xlibs; "${mesa}/lib:${libX11}/lib:${libXcursor}/lib:${libXxf86vm}/lib:${libXi}/lib:${SDL2}/lib";

   subnet = ''
   'maths_boolean:(boolean=false)' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})
   'maths_boolean:(boolean=false)' -> a nand(${maths_boolean_nand}) output -> input disp(${maths_boolean_print})
   'maths_boolean:(boolean=false)' -> b nand()

   button(${ui_conrod_button}) output -> input print(${print})
   'generic_text:(text="Receive at output")' -> option print()

   button() output[button_clicked] -> input print_clicked(${print})
   'generic_text:(text="A button is clicked")' -> option print_clicked()

   'path:(path="${doc}/share/doc/fractalide/")' -> www_dir www(${web_server})
   'domain_port:(domainPort="localhost:8083")' -> domain_port www()
   'url:(url="/docs")' -> url www()
   'generic_text:(text="[*] serving: localhost:8083/docs/manual.html")' -> input disp(${io_print})



   'maths_boolean:(boolean=true)' -> input window(${ui_conrod_window})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: development testing file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
