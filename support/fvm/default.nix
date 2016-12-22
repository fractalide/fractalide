{ buffet }:

let
fvm  = buffet.support.executable {
  name = "fvm";
  src = ./.;
  crates = with buffet.crates; [ rustfbp capnp ];
  configurePhase = with buffet.nodes; with buffet.edges; ''
    runHook preConfigure
    substituteInPlace src/main.rs --replace "fs_file_open.so" "${fs_file_open}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_parser_lexical.so" "${core_parser_lexical}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_parser_semantic.so" "${core_parser_semantic}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_vm.so" "${core_vm}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_errors.so" "${core_errors}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_parser_graph_print.so" "${core_parser_graph_print}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_parser_graph_check.so" "${core_parser_graph_check}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_scheduler.so" "${core_scheduler}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_capnp_encode.so" "${core_capnp_encode}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "halter.so" "${halter}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_find_edge.so" "${core_find_edge}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "core_find_node.so" "${core_find_node}/lib/libagent.so"

    substituteInPlace src/main.rs --replace "path_capnp.rs" "${path}/src/edge_capnp.rs"
    substituteInPlace src/main.rs --replace "fbp_action.rs" "${fbp_action}/src/edge_capnp.rs"
  '';
};
in
fvm
