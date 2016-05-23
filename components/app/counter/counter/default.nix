{ stdenv, buildFractalideSubnet, upkeepers
  , app_counter_card
  , ui_js_page
  , ...}:
  let
  doc = import ../../../doc {};
  in
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   counter(${app_counter_card}) output -> input page(${ui_js_page})
   'generic_text:(text="hello")~create' -> input counter()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
