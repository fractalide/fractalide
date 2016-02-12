{pkgs, components, contracts, support, fbp, ...}:

let
subnetDeps = support.filterDeps (support.extractDepsFromSubnet fbp);
fvm  = support.buildRustPackage rec {
    name = "fvm";
    src = ./.;
    depsSha256 = "13k03lbs6gk8zwbzzlvh3s2x3c4hj3jj479hg1jwkzrpxlkirglw";
    configurePhase = ''
    mkdir -p $out/per-session
    mkdir -p per-session

    ln -s ${components.file_open}/lib/libcomponent.so $out/per-session/${components.file_open.name}.so
    ln -s ${components.file_open}/lib/libcomponent.so per-session/${components.file_open.name}.so
    ln -s ${components.file_print}/lib/libcomponent.so $out/per-session/${components.file_print.name}.so
    ln -s ${components.file_print}/lib/libcomponent.so per-session/${components.file_print.name}.so
    ln -s ${components.development_fbp_parser_lexical}/lib/libcomponent.so $out/per-session/${components.development_fbp_parser_lexical.name}.so
    ln -s ${components.development_fbp_parser_lexical}/lib/libcomponent.so per-session/${components.development_fbp_parser_lexical.name}.so
    ln -s ${components.development_fbp_parser_semantic}/lib/libcomponent.so $out/per-session/${components.development_fbp_parser_semantic.name}.so
    ln -s ${components.development_fbp_parser_semantic}/lib/libcomponent.so per-session/${components.development_fbp_parser_semantic.name}.so
    ln -s ${components.development_fbp_parser_print_graph}/lib/libcomponent.so $out/per-session/${components.development_fbp_parser_print_graph.name}.so
    ln -s ${components.development_fbp_parser_print_graph}/lib/libcomponent.so per-session/${components.development_fbp_parser_print_graph.name}.so
    ln -s ${components.development_capnp_encode}/lib/libcomponent.so $out/per-session/${components.development_capnp_encode.name}.so
    ln -s ${components.development_capnp_encode}/lib/libcomponent.so per-session/${components.development_capnp_encode.name}.so
    ln -s ${components.development_fbp_fvm}/lib/libcomponent.so $out/per-session/${components.development_fbp_fvm.name}.so
    ln -s ${components.development_fbp_fvm}/lib/libcomponent.so per-session/${components.development_fbp_fvm.name}.so
    ln -s ${components.development_fbp_errors}/lib/libcomponent.so $out/per-session/${components.development_fbp_errors.name}.so
    ln -s ${components.development_fbp_errors}/lib/libcomponent.so per-session/${components.development_fbp_errors.name}.so
    ln -s ${components.development_fbp_scheduler}/lib/libcomponent.so $out/per-session/${components.development_fbp_scheduler.name}.so
    ln -s ${components.development_fbp_scheduler}/lib/libcomponent.so per-session/${components.development_fbp_scheduler.name}.so
    ln -s ${support.component_lookup}/lib/libcomponent.so $out/per-session/${support.component_lookup.name}.so
    ln -s ${support.component_lookup}/lib/libcomponent.so per-session/${support.component_lookup.name}.so
    ln -s ${support.contract_lookup}/lib/libcomponent.so $out/per-session/${support.contract_lookup.name}.so
    ln -s ${support.contract_lookup}/lib/libcomponent.so per-session/${support.contract_lookup.name}.so

    ${pkgs.stdenv.lib.concatMapStringsSep "\n"
      (dep: "ln -sf ${dep.outPath}/lib/libcomponent.so $out/per-session/${dep.name}.so;")
      (pkgs.stdenv.lib.flatten subnetDeps)}

    ln -s ${pkgs.capnproto}/bin/capnp $out/per-session/capnp

    substituteInPlace src/lib.rs --replace "path_capnp.rs" "${contracts.path}/src/contract_capnp.rs"
    '';

    setupHook = ./setup-hook.sh;

    meta = with pkgs.stdenv.lib; {
      description = "Fractalide Virtual Machine";
      homepage = https://github.com/fractalide/fractalide;
      license = with licenses; [ agpl3Plus ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie ];
    };
  };
  in
fvm
