{ stdenv, buildFractalideSubnet, upkeepers
  , debug
  , ui_js_button
  , ui_js_block
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   input => input button(${ui_js_button}) output -> places[0] lr(${ui_js_block}) output => output
   'js_button:(label="button test")' -> acc button()

   'js_block:(css="display: flex;")' -> acc lr()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
