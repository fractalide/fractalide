{ stdenv, buildFractalideSubnet, upkeepers
  , app_counter_add
  , app_counter_minus
  , app_counter_view
  , app_model
  , ip_dispatcher
  , ...}:
  let
  doc = import ../../../doc {};
  in
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output

   model(${app_model}) output -> input view(${app_counter_view}) output -> input out_dispatch()
   'generic_i64:(number=0)' -> acc model()
   out_dispatch() output[add] -> input model()
   out_dispatch() output[minus] -> input model()

   model() compute[add] -> input add(${app_counter_add}) output -> result model()
   model() compute[minus] -> input minus(${app_counter_minus}) output -> result model()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
