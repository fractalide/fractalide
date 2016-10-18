{ stdenv
  , buildFractalideSubnet
  , encryptComponent
  , upkeepers
  # components
  , shells_lain_commands_print
  , shells_lain_commands_dirname
  # contracts
  , command, generic_text
  , ...}:

  buildFractalideSubnet rec {
    src = ./.;
    subnet = ''
    shells_lain_commands_dirname_0(${encryptComponent shells_lain_commands_dirname}) stdout ->
      stdin shells_lain_commands_print_1(${shells_lain_commands_print})
    '${command}:(name="shells_lain_commands_dirname", singles=["-z"], kvs=[])' -> option shells_lain_commands_dirname_0()
    '${generic_text}:(text="/2/1")' -> stdin shells_lain_commands_dirname_0()
    '${command}:(name="shells_lain_commands_print", singles=[], kvs=[])' -> option shells_lain_commands_print_1()

    '';
    meta = with stdenv.lib; {
      description = "Subnet: Counter app";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
