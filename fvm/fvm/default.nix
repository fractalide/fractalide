{pkgs
  , stdenv ? pkgs.stdenv
  , rustUnstable ? pkgs.rustUnstable
  , rustRegistry ? support.rustRegistry
  , buildRustPackage ? support.buildRustPackage
  , upkeepers ? support.upkeepers
  , support, components, contracts,
  }:

  with rustUnstable rustRegistry;

  buildRustPackage rec {
    name = "fvm";
    src = ./.;
    depsSha256 = "13f0fyjc9hphzqxh21qr7lcdjv1s617g3ccgxs5l17bgjg5z887l";

    configurePhase = ''
    mkdir -p $out/bootstrap
    mkdir -p bootstrap

    cp ${components.file_open}/lib/libcomponent.so $out/bootstrap/${components.file_open.name}.so
    ln -s ${components.file_open}/lib/libcomponent.so bootstrap/${components.file_open.name}.so
    cp ${components.file_print}/lib/libcomponent.so $out/bootstrap/${components.file_print.name}.so
    ln -s ${components.file_print}/lib/libcomponent.so bootstrap/${components.file_print.name}.so
    cp ${components.development_fbp_parser_lexical}/lib/libcomponent.so $out/bootstrap/${components.development_fbp_parser_lexical.name}.so
    ln -s ${components.development_fbp_parser_lexical}/lib/libcomponent.so bootstrap/${components.development_fbp_parser_lexical.name}.so
    cp ${components.development_fbp_parser_semantic}/lib/libcomponent.so $out/bootstrap/${components.development_fbp_parser_semantic.name}.so
    ln -s ${components.development_fbp_parser_semantic}/lib/libcomponent.so bootstrap/${components.development_fbp_parser_semantic.name}.so
    cp ${components.development_fbp_parser_print_graph}/lib/libcomponent.so $out/bootstrap/${components.development_fbp_parser_print_graph.name}.so
    ln -s ${components.development_fbp_parser_print_graph}/lib/libcomponent.so bootstrap/${components.development_fbp_parser_print_graph.name}.so
    cp ${components.development_capnp_encode}/lib/libcomponent.so $out/bootstrap/${components.development_capnp_encode.name}.so
    ln -s ${components.development_capnp_encode}/lib/libcomponent.so bootstrap/${components.development_capnp_encode.name}.so
    cp ${components.development_fbp_fvm}/lib/libcomponent.so $out/bootstrap/${components.development_fbp_fvm.name}.so
    ln -s ${components.development_fbp_fvm}/lib/libcomponent.so bootstrap/${components.development_fbp_fvm.name}.so
    cp ${components.development_fbp_errors}/lib/libcomponent.so $out/bootstrap/${components.development_fbp_errors.name}.so
    ln -s ${components.development_fbp_errors}/lib/libcomponent.so bootstrap/${components.development_fbp_errors.name}.so
    cp ${components.development_fbp_scheduler}/lib/libcomponent.so $out/bootstrap/${components.development_fbp_scheduler.name}.so
    ln -s ${components.development_fbp_scheduler}/lib/libcomponent.so bootstrap/${components.development_fbp_scheduler.name}.so
    cp ${support.component_lookup}/lib/libcomponent.so $out/bootstrap/${support.component_lookup.name}.so
    ln -s ${support.component_lookup}/lib/libcomponent.so bootstrap/${support.component_lookup.name}.so
    cp ${support.contract_lookup}/lib/libcomponent.so $out/bootstrap/${support.contract_lookup.name}.so
    ln -s ${support.contract_lookup}/lib/libcomponent.so bootstrap/${support.contract_lookup.name}.so

    cp ${pkgs.capnproto}/bin/capnp $out/bootstrap/capnp

    substituteInPlace src/lib.rs \
    --replace "path_capnp.rs" "${contracts.path}/src/contract_capnp.rs"
    '';

    meta = with stdenv.lib; {
      description = "Fractalide Virtual Machine";
      homepage = https://github.com/fractalide/fractalide;
      license = with licenses; [ agpl3Plus ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie ];
    };
  }

