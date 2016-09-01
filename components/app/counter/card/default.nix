{ stdenv, buildFractalideSubnet, upkeepers
  , app_counter_add
  , app_counter_delta
  , app_counter_minus
  , app_counter_view
  , app_model
  , debug
  , ip_clone
  , ip_dispatcher
  # contracts
  , generic_i64
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output

   model(${app_model}) output -> input view(${app_counter_view}) output -> input out_dispatch()


   '${generic_i64}:(number=0)' -> acc model()
   out_dispatch() output[add] -> input model()
   out_dispatch() output[minus] -> input model()
   out_dispatch() output[delta] -> input model()

   in_dispatch() output[create] -> input clone_create(${ip_clone})
   clone_create() clone[0] -> input view()
   clone_create() clone[1] -> input model()

   in_dispatch() output[delete] -> input view()

   model() compute[add] -> input add(${app_counter_add}) output -> result model()
   model() compute[minus] -> input minus(${app_counter_minus}) output -> result model()
   model() compute[delta] -> input delta(${app_counter_delta}) output -> result model()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
