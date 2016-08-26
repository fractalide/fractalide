{ stdenv, buildFractalideSubnet, upkeepers
  , shells_fsh_prompt
  , shells_fsh_lexer
  , shells_fsh_parser
  , io_print_list_text
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   name = "fsh";
   subnet = ''
   'shell_commands:(commands=[ (key="cd", val="shells_commands_cd"),(key="ls", val="shells_commands_ls"),(key="pwd", val="shells_commands_pwd")])~create' ->
   commands lexer()

   prompt(${shells_fsh_prompt}) output ->
      input lexer(${shells_fsh_lexer}) output ->
      input parser(${shells_fsh_parser}) output ->
      input print_list_text(${io_print_list_text})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
