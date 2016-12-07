{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
   // Basic output
   open(${fs_file_open}) output -> input lex(${nucleus_flow_parser_lexical})
   lex() output -> input sem(${nucleus_flow_parser_semantic})
   sem() output -> input check(${nucleus_flow_parser_graph_check})
   check() output -> input vm(${nucleus_flow_vm})

   open() error -> file_error errors(${nucleus_flow_errors})
   sem() error -> semantic_error errors()
   check() error -> semantic_error errors()

   errors() output -> input vm()

   vm() ask_graph -> input open()

   // Send to sched
   vm() output -> graph sched(${nucleus_flow_scheduler})
   sched() ask_path -> input nucleus_find_edge(${nucleus_find_edge})
   nucleus_find_edge() output -> edge_path sched()

   vm() ask_path -> input nucleus_find_node(${nucleus_find_node})
   nucleus_find_node() output -> new_path vm()

   sched() ask_graph -> input vm()

   // IIP
   sched() iip_path -> path iip(${nucleus_capnp_encode})
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
