{ pkgs, support, nodes, edges, crates }:

let
fvm  = support.rustBinary {
    name = "fvm";
    src = ./.;
    binary = "bin";
    crates = with crates; [ rustfbp capnp ];
    depsSha256 = "1zwf62xbpby6s56kz24xs5ypg62slabh85c3f1995d11v89cgai9";
    configurePhase = with nodes; with edges; ''
    runHook preConfigure
    substituteInPlace src/main.rs --replace "fs_file_open.so" "${fs_file_open}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_flow_parser_lexical.so" "${nucleus_flow_parser_lexical}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_flow_parser_semantic.so" "${nucleus_flow_parser_semantic}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_flow_vm.so" "${nucleus_flow_vm}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_flow_errors.so" "${nucleus_flow_errors}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_flow_parser_graph_print.so" "${nucleus_flow_parser_graph_print}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_flow_parser_graph_check.so" "${nucleus_flow_parser_graph_check}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_flow_scheduler.so" "${nucleus_flow_scheduler}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_capnp_encode.so" "${nucleus_capnp_encode}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "halter.so" "${halter}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_find_edge.so" "${nucleus_find_edge}/lib/libagent.so"
    substituteInPlace src/main.rs --replace "nucleus_find_node.so" "${nucleus_find_node}/lib/libagent.so"

    substituteInPlace src/main.rs --replace "path_capnp.rs" "${path}/src/edge_capnp.rs"
    substituteInPlace src/main.rs --replace "fbp_action.rs" "${fbp_action}/src/edge_capnp.rs"
    '';


    installPhase = ''
      runHook preInstall
    '';

    meta = with pkgs.stdenv.lib; {
      description = "Fractalide Virtual Machine";
      homepage = https://github.com/fractalide/fractalide;
      license = with licenses; [ mpl20 ];
      maintainers = with support.upkeepers; [ dmichiels sjmackenzie ];
  };
};
in
fvm
