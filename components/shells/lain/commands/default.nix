{ stdenv, buildFractalideSubnet, upkeepers
  , shells_lain_commands_print
  , shells_lain_commands_dirname
  # contracts
  , command, generic_text
  , ...}:
  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    shells_lain_commands_print(${shells_lain_commands_print}) stdout ->
      stdin shells_lain_commands_dirname_0(${shells_lain_commands_dirname}) stdout ->
      stdin shells_lain_commands_print_1(${shells_lain_commands_print}) stdout ->
      stdin shells_lain_commands_dirname_2(${shells_lain_commands_dirname}) stdout ->
      stdin shells_lain_commands_print_3(${shells_lain_commands_print}) stdout ->
      stdin shells_lain_commands_dirname_4(${shells_lain_commands_dirname}) stdout ->
      stdin shells_lain_commands_print_5(${shells_lain_commands_print}) stdout ->
      stdin shells_lain_commands_dirname_6(${shells_lain_commands_dirname}) stdout ->
      stdin shells_lain_commands_print_7(${shells_lain_commands_print})
    '${generic_text}:(text="/3/2/1")' -> stdin shells_lain_commands_print()
    '${command}:(singles=["print_1"])' -> option shells_lain_commands_print()
    '${command}:(singles=["-z", "--z2ero"])' -> option shells_lain_commands_dirname_0()
    '${command}:(singles=["print_1"])' -> option shells_lain_commands_print_1()
    '${command}:(singles=["-z", "--z2ero"])' -> option shells_lain_commands_dirname_2()
    '${command}:(singles=["print_2"])' -> option shells_lain_commands_print_3()
    '${command}:(singles=["-z", "--z2ero"])' -> option shells_lain_commands_dirname_4()
    '${command}:(singles=["print_3"])' -> option shells_lain_commands_print_5()
    '${command}:(singles=["-z", "--z2ero"])' -> option shells_lain_commands_dirname_6()
    '${command}:(singles=["print_3"])' -> option shells_lain_commands_print_7()
    '';
    meta = with stdenv.lib; {
      description = "Subnet: Counter app";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
