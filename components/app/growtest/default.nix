{ stdenv, buildFractalideSubnet, upkeepers
  , app_button_card
  , app_counter_card
  , debug
  , ip_delay
  , ui_js_growing_block
  , ui_js_page
  , development_fbp_subnet
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''

   gblock(${ui_js_growing_block}) output -> input page(${ui_js_page})
   'generic_text:(text="${app_counter_card}")' -> option gblock()

   'generic_text:(text="dummy")' -> input page()

   gblock() scheduler -> action sched(${development_fbp_subnet})
   sched() outputs[td] -> input page()

   // 'generic_text:(text="")~add' -> input gblock()
   'generic_text:(text="")~add' -> input gblock()

   'generic_text:(text="")~add' ->
       input d1(${ip_delay}) output ->
       input d2(${ip_delay}) output ->
       input d3(${ip_delay}) output ->
       input gblock()

    'generic_text:(text="")~add' ->
        input d11(${ip_delay}) output ->
        input d12(${ip_delay}) output ->
        input d13(${ip_delay}) output ->
        input d14(${ip_delay}) output ->
        input d15(${ip_delay}) output ->
        input d16(${ip_delay}) output ->
        input gblock()

    'generic_text:(text="")~remove' ->
        input d21(${ip_delay}) output ->
        input d22(${ip_delay}) output ->
        input d23(${ip_delay}) output ->
        input d24(${ip_delay}) output ->
        input d25(${ip_delay}) output ->
        input d26(${ip_delay}) output ->
        input d27(${ip_delay}) output ->
        input d28(${ip_delay}) output ->
        input d29(${ip_delay}) output ->
        input gblock()

    'generic_text:(text="")~remove' ->
        input d31(${ip_delay}) output ->
        input d32(${ip_delay}) output ->
        input d33(${ip_delay}) output ->
        input d34(${ip_delay}) output ->
        input d35(${ip_delay}) output ->
        input d36(${ip_delay}) output ->
        input d37(${ip_delay}) output ->
        input d38(${ip_delay}) output ->
        input d39(${ip_delay}) output ->
        input d371(${ip_delay}) output ->
        input d381(${ip_delay}) output ->
        input d391(${ip_delay}) output ->
        input gblock()

   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
