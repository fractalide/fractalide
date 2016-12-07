{ subgraph, nodes, edges}:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
  shells_lain_commands_dirname_0(${shells_lain_commands_dirname}) stdout ->
    stdin shells_lain_commands_print_1(${shells_lain_commands_print})
  '${command}:(name="shells_lain_commands_dirname", singles=["-z"], kvs=[])' -> option shells_lain_commands_dirname_0()
  '${generic_text}:(text="/2/1")' -> stdin shells_lain_commands_dirname_0()
  '${command}:(name="shells_lain_commands_print", singles=[], kvs=[])' -> option shells_lain_commands_print_1()
  '';
}
