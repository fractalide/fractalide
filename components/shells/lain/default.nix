{ stdenv, buildFractalideSubnet, upkeepers
  , shells_lain_prompt
  , shells_lain_pipe
  , shells_lain_parse
  , shells_lain_flow
  , io_print
  # contracts
  , shell_commands
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   name = "lain";
   subnet = ''
   '${shell_commands}:(commands=[ (key="cd", val="shells_commands_cd"),(key="ls", val="shells_commands_ls"),(key="pwd", val="shells_commands_pwd")])~create' ->
   option parse()

   prompt(${shells_lain_prompt}) output ->
   input pipe(${shells_lain_pipe}) output ->
   input parse(${shells_lain_parse}) output ->
   input flow(${shells_lain_flow}) output ->
   input print(${io_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Fractalide Shell";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
