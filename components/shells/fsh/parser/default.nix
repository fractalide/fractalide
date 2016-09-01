{ stdenv, buildFractalideSubnet, upkeepers
  , shells_fsh_parser_verify
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input pipes(${shells_fsh_parser_verify}) output => output
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
