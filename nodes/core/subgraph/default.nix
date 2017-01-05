{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
   // Basic output
   open(${fs_file_open}) output -> input lex(${core_parser_lexical})
   lex() output -> input sem(${core_parser_semantic})
   sem() output -> input check(${core_parser_graph_check})
   check() output -> input vm(${core_vm})

   open() error -> file_error errors(${core_errors})
   sem() error -> semantic_error errors()
   check() error -> semantic_error errors()

   errors() output -> input vm()

   vm() ask_graph -> input open()

   // Send to sched
   vm() output -> graph sched(${core_scheduler})
   sched() ask_path -> input core_find_edge(${core_find_edge})
   core_find_edge() output -> edge_path sched()

   vm() ask_path -> input core_find_node(${core_find_node})
   core_find_node() output -> new_path vm()

   sched() ask_graph -> input vm()

   // IIP
   sched() iip_path -> path iip(${core_capnp_encode})
   sched() iip_edge -> edge iip()
   sched() iip_input -> input iip()
   iip() output -> iip sched()

   sched() outputs[test] -> input cl(${fs_file_open})

   action => action sched()
   sched() outputs => outputs

   // used to send in a flow string.
   flowscript => input lex()
   '';
}
