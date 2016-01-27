{pkgs
  , stdenv ? pkgs.stdenv
  , rustUnstable ? support.rustUnstable
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
    substituteInPlace src/lib.rs \
    --replace "path_capnp.rs" "${contracts.path}/src/contract_capnp.rs" \
    --replace "component_lookup.so" "${support.component_lookup}/lib/libcomponent.so" \
    --replace "contract_lookup.so" "${support.contract_lookup}/lib/libcomponent.so" \
    --replace "file_open.so" "${components.file_open}/lib/libcomponent.so" \
    --replace "file_print.so" "${components.file_print}/lib/libcomponent.so" \
    --replace "development_fbp_errors.so" "${components.development_fbp_errors}/lib/libcomponent.so" \
    --replace "development_fbp_fvm.so" "${components.development_fbp_fvm}/lib/libcomponent.so" \
    --replace "development_fbp_parser_lexical.so" "${components.development_fbp_parser_lexical}/lib/libcomponent.so" \
    --replace "development_fbp_parser_semantic.so" "${components.development_fbp_parser_semantic}/lib/libcomponent.so" \
    --replace "development_fbp_parser_print_graph.so" "${components.development_fbp_parser_print_graph}/lib/libcomponent.so" \
    --replace "development_fbp_scheduler.so" "${components.development_fbp_scheduler}/lib/libcomponent.so" \
    '';

    meta = with stdenv.lib; {
      description = "Fractalide Virtual Machine";
      homepage = https://github.com/fractalide/fractalide;
      license = with licenses; [ agpl3Plus ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie ];
    };
  }

