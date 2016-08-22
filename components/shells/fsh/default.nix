{ stdenv, buildFractalideSubnet, upkeepers
  , shells_fsh_prompt
  , shells_fsh_parse
  , io_print
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   name = "fsh";
   subnet = ''
   prompt(${shells_fsh_prompt}) output -> parse parse(${shells_fsh_parse}) output -> input print(${io_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
