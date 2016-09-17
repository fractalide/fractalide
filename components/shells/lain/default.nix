{ stdenv, buildFractalideSubnet, upkeepers
  , shells_lain_prompt
  , shells_lain_parse
  , shells_lain_flow
  , nucleus_flow_subnet
  , io_print
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   name = "lain";
   subnet = ''
     prompt(${shells_lain_prompt}) output ->
     input parse(${shells_lain_parse}) output ->
     input flow(${shells_lain_flow}) output ->
     flowscript scheduler(${nucleus_flow_subnet}) outputs ->
     input print(${io_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
