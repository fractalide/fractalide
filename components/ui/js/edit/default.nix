{ stdenv, buildFractalideSubnet, upkeepers
  , ui_js_edit_view
  , ui_js_edit_contentedited
  , app_model
  , ip_dispatcher
  , debug
  , ...}:
  let
  doc = import ../../../doc {};
  in
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output

   model(${app_model}) output -> input d(${debug}) output -> input view(${ui_js_edit_view}) output -> input out_dispatch()
   'generic_text:(text="this is a test")' -> option d()


   'generic_text:(text="this is a test")' -> acc model()

   in_dispatch() output[create] -> input view()
   in_dispatch() output[delete] -> input view()


   view() output[get_model] -> input model()
   view() output[content_edited] -> input model()

   model() compute[content_edited] -> input ce(${ui_js_edit_contentedited}) output -> result model()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: editor card";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
