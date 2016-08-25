{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Contract: Mappings used to convert a complex hierarchical name such as 'shell_commands_cd' to 'cd'.";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/shells/commands;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
