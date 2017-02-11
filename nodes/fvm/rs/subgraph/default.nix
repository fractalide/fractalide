{ subgraph, nodes }:

subgraph {
  src = ./.;
  flowscript = with nodes; ''
   // Basic output
   open(${rs_fs_file_open}) output -> input lex(${fvm_rs_parser_lexical})
   lex() output -> input sem(${fvm_rs_parser_semantic})
   sem() output -> input check(${fvm_rs_parser_graph_check})
   check() output -> input vm(${fvm_rs_vm})

   open() error -> file_error errors(${fvm_rs_errors})
   sem() error -> semantic_error errors()
   check() error -> semantic_error errors()

   errors() output -> input vm()

   vm() ask_graph -> input open()

   // Send to sched
   vm() output -> graph sched(${fvm_rs_scheduler})
   vm() ask_path -> input core_find_node(${fvm_rs_find_node})
   core_find_node() output -> new_path vm()

   sched() ask_graph -> input vm()

   sched() outputs[test] -> input cl(${rs_fs_file_open})

   action => action sched()
   sched() outputs => outputs

   // used to send in a flow string.
   flowscript => input lex()
   '';
}
