{ stdenv, buildFractalideSubnet, upkeepers
  , shells_fsh_lexer_pipe
  , shells_fsh_lexer_tokenize
  , ...}:
  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   input => input pipes(${shells_fsh_lexer_pipe}) output ->
      input tokenize(${shells_fsh_lexer_tokenize}) output => output

   commands => option tokenize()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
