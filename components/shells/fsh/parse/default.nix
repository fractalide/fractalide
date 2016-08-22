{ stdenv, buildFractalideSubnet, upkeepers
  , shells_fsh_parse_pipe
  , shells_fsh_build_names
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   parse => parse parse(${shells_fsh_parse_pipe}) output -> input build(${shells_fsh_build_names}) output => output
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
