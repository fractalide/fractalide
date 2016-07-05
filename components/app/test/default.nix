{ stdenv, buildFractalideSubnet, upkeepers
  , debug
  , app_counter_view
  , ip_delay
  , ui_js_page
  , ui_js_placeholder
  , ui_js_flex
  , ui_js_tag
  , ui_js_edit
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   td(${ui_js_flex}) output -> input page(${ui_js_page})
   'js_tag:(type="div", css=[(key="display", value="flex"), (key="flex-direction", value="column")])~create' -> input td()

   edit(${ui_js_edit}) output -> places[0] td()
   'generic_text:(text="initial value")~create' -> input edit()


   // counter(${app_counter_view}) output -> places[0] td()

   // td(${ui_js_flex}) output -> input page(${ui_js_page})
   // 'js_tag:(type="div", css=[(key="display", value="flex"), (key="flex-direction", value="column")])' -> input td()

   // lr(${ui_js_flex}) output -> places[0] td()
   // 'js_tag:(type="div", css=[(key="display", value="flex")])' -> input lr()

   // 'js_tag:(type="button", content="+")' -> input button2(${ui_js_tag})
   // 'js_tag:(type="span", content="0", css=[(key="maring", value="0 10px")])' -> input text(${ui_js_tag})


   'js_tag:(type="svg", attributes=[(key="width", value="200"), (key="height", value="200")])~create' -> input svg(${ui_js_flex}) output -> places[1] td()

   'js_tag:(type="circle", attributes=[(key="cx", value="50"), (key="cy", value="50"), (key="r", value="40"), (key="fill", value="yellow"), (key="stroke", value="green"), (key="stroke-width", value="4")])~create' -> input circl(${ui_js_tag}) output -> places[0] svg()

   // button2() output -> places[2] lr()
   // text() output -> places[1] lr()


   // input(${ui_js_tag}) output -> places[1] td()
   // 'js_tag:(type="input", attributes=[(key="value", value="1")])' -> input input()



    // 'js_tag:(type="div", css=[(key="display", value="flex")])~create' -> input taglr(${ui_js_flex}) output -> places[5] td()

    // 'js_tag:(type="img", attributes=[(key="src", value="/home/denis/29_jpg.jpg")])~create' -> input tag3(${ui_js_tag}) output -> places[0] taglr()
    // 'js_tag:(type="button", content="test")~create' -> input tag4(${ui_js_tag}) output -> places[1] taglr()


    // 'js_tag:(type="div")~create' -> input tagvis(${ui_js_placeholder}) output -> places[6] td()
    // 'js_tag:(type="img", attributes=[(key="src", value="/home/denis/29_jpg.jpg")])~create' -> input tag13(${ui_js_tag}) output -> places[0] tagvis()
    // 'js_tag:(type="img", attributes=[(key="src", value="/home/denis/carte_id.jpg")])~create' -> input tag14(${ui_js_tag}) output -> places[1] tagvis()
    // 'generic_text:(text="")~display' -> input tag13()

    // 'generic_text:(text="a test")~set_content' ->
    //     input d11(${ip_delay}) output ->
    //     input d12(${ip_delay}) output ->
    //     input d13(${ip_delay}) output ->
    //     input d14(${ip_delay}) output ->
    //     input tag1()

    // 'generic_text:(text="delete")~display' ->
    // input d111(${ip_delay}) output ->
    // input d112(${ip_delay}) output ->
    // input d113(${ip_delay}) output ->
    // input d114(${ip_delay}) output ->
    // input d115(${ip_delay}) output ->
    // input d116(${ip_delay}) output ->
    // input b1()
    
    // 'js_tag:(type="button", content="ultimate test")~create' ->
    //     input d111(${ip_delay}) output ->
    //     input d112(${ip_delay}) output ->
    //     input d113(${ip_delay}) output ->
    //     input d114(${ip_delay}) output ->
    //     input d115(${ip_delay}) output ->
    //     input d116(${ip_delay}) output ->
    //     input tag6(${ui_js_tag}) output -> places[1] ordererlr()

    // 'js_tag:(type="button", content="ultimate test")~display' ->
    //         input d1111(${ip_delay}) output ->
    //         input d1112(${ip_delay}) output ->
    //         input d1113(${ip_delay}) output ->
    //         input d1114(${ip_delay}) output ->
    //         input d1115(${ip_delay}) output ->
    //         input d1116(${ip_delay}) output ->
    //         input d1117(${ip_delay}) output ->
    //         input d1118(${ip_delay}) output ->
    //         input tag14()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
