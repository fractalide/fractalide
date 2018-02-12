{ buffet }:

buffet.support.node.rs.fvm {
  name = "fvm";
  src = ./.;
  libPath = "main.rs";
  mods = with buffet.mods.rs; [ (rustfbp_0_3_34 {}) (capnp_0_8_15 {}) ];
  edges = with buffet.edges.rs; [ CoreAction ];
  postInstall = with buffet.nodes; ''
    cp $src/main.rs $out/src
    substituteInPlace $out/src/main.rs --replace "fs_file_open.so" "${rs.fs_file_open}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_parser_lexical.so" "${fvm_rs_parser_lexical}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_parser_semantic.so" "${fvm_rs_parser_semantic}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_parser_graph_check.so" "${fvm_rs_parser_graph_check}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_vm.so" "${fvm_rs_vm}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_errors.so" "${fvm_rs_errors}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_parser_graph_print.so" "${fvm_rs_parser_graph_print}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_scheduler.so" "${fvm_rs_scheduler}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_find_node.so" "${fvm_rs_find_node}/lib/libagent.so"
    substituteInPlace $out/src/main.rs --replace "core_start.so" "${fvm_rs_start}/lib/libagent.so"
  '';
}
