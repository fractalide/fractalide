{ stdenv, buildFractalideSubnet, upkeepers
  , debug
  , ip_delay
  , ui_js_page
  , ui_js_button
  , ui_js_block
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   td(${ui_js_block}) output -> input page(${ui_js_page})
    'js_block:(places=[], css="display: flex; flex-direction: column;")' -> acc td()

    block(${ui_js_block}) output -> places[1] td()
    'js_block:(places=[], css="display: flex;")' -> acc block()

    'js_button:(label="1", disabled=true, css="color:red;", blockCss="")' -> acc b1(${ui_js_button})
    'generic_text:(text="create")~create' -> input b1()
    b1() output -> places[1] block()

    'js_button:(label="2", css="color:green;", blockCss="")' -> acc b2(${ui_js_button})
    'generic_text:(text="create")~create' -> input b2()
    b2() output -> places[2] block()

    'js_button:(label="3")' -> acc b3(${ui_js_button})
    'generic_text:(text="create")~create' -> input b3()
    b3() output -> places[2] td()
    // 'generic_text:(text="testcreate")~testcreate' -> input d1(${ip_delay}) output -> input d2(${ip_delay}) output -> input b1()

    b3() output[click] -> input display(${debug})
    'generic_text:(text="button 3 is clicked")' -> option display()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
