{ stdenv, buildFractalideSubnet, upkeepers
  , shells_lain_commands_print
  # contracts
  , generic_text
  , ...}:
  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    shells_lain_commands_print_0(shells_lain_commands_print) output ->
        input shells_lain_commands_print_1(shells_lain_commands_print) output ->
        input shells_lain_commands_print_2(shells_lain_commands_print) output ->
        input shells_lain_commands_print_3(shells_lain_commands_print)
    'generic_text:(text="start")' -> input shells_lain_commands_print_0()
    'generic_text:(text="initial0")' -> option shells_lain_commands_print_0()
    'generic_text:(text="initial1")' -> option shells_lain_commands_print_1()
    'generic_text:(text="initial2")' -> option shells_lain_commands_print_2()
    'generic_text:(text="initial3")' -> option shells_lain_commands_print_3()
    '';
    meta = with stdenv.lib; {
      description = "Subnet: Counter app";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
