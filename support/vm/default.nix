{pkgs, components, contracts, support, exeSubnet, ...}:

let
vm  = support.buildRustPackage rec {
    name = exeSubnet.name;
    src = ./.;
    depsSha256 = "1cn9ln24cr6dvxhl3f5kp0qpjrv4w2lwhhy1b23g3plbfipvarnd";
    exportReferencesGraph = [ "contract_lookup-graph" support.contract_lookup ];
    configurePhase = ''
    runHook preConfigure
    substituteInPlace src/lib.rs --replace "fs_file_open.so" "${components.fs_file_open}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_fbp_parser_lexical.so" "${components.development_fbp_parser_lexical}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_fbp_parser_semantic.so" "${components.development_fbp_parser_semantic}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_fbp_vm.so" "${components.development_fbp_vm}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_fbp_errors.so" "${components.development_fbp_errors}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_fbp_parser_print_graph.so" "${components.development_fbp_parser_print_graph}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_fbp_parser_check_graph.so" "${components.development_fbp_parser_check_graph}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_fbp_scheduler.so" "${components.development_fbp_scheduler}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "development_capnp_encode.so" "${components.development_capnp_encode}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "halter.so" "${components.halter}/lib/libcomponent.so"
    substituteInPlace src/lib.rs --replace "contract_lookup.so" "${support.contract_lookup}/lib/libcomponent.so"

    substituteInPlace src/lib.rs --replace "path_capnp.rs" "${contracts.path}/src/contract_capnp.rs"
    substituteInPlace src/lib.rs --replace "fbp_action.rs" "${contracts.fbp_action}/src/contract_capnp.rs"
    substituteInPlace Cargo.toml --replace "vm" "${name}"
    substituteInPlace src/main.rs --replace "vm" "${name}"
    substituteInPlace src/main.rs --replace "nix-replace-me" "${exeSubnet}"
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
vm
