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

    b3() output[click] -> input display(${debug})
    'generic_text:(text="button 3 is clicked")' -> option display()

    'generic_text:(text="delete")~delete' -> input d1(${ip_delay}) output -> input d2(${ip_delay}) output -> input b1()

    'generic_text:(text="delete")~delete' ->
        input d11(${ip_delay}) output ->
        input d12(${ip_delay}) output ->
        input d13(${ip_delay}) output ->
        input d14(${ip_delay}) output ->
        input b2()

    'generic_text:(text="delete")~delete' ->
    input d111(${ip_delay}) output ->
    input d112(${ip_delay}) output ->
    input d113(${ip_delay}) output ->
    input d114(${ip_delay}) output ->
    input d115(${ip_delay}) output ->
    input d116(${ip_delay}) output ->
    input b3()
    
    //'js_button:(label="5", css="color:green;", blockCss="")' -> acc b12(${ui_js_button})
    //'generic_text:(text="create")~create' -> input b12()
    //b12() output ->
    //    input d111(${ip_delay}) output ->
    //    input d112(${ip_delay}) output ->
    //    input d113(${ip_delay}) output ->
    //    input d114(${ip_delay}) output ->
    //    input d115(${ip_delay}) output ->
    //    input d116(${ip_delay}) output ->
    //    places[1] block()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
