{pkgs, components, contracts, support, fbp, ...}:

let
subnetDeps = support.filterDeps (support.extractDepsFromSubnet fbp);

fvm  = support.buildRustPackage rec {
    name = "fvm_${(builtins.head (pkgs.stdenv.lib.splitString "." (builtins.baseNameOf fbp)))}";
    src = ./.;
    depsSha256 = "13k03lbs6gk8zwbzzlvh3s2x3c4hj3jj479hg1jwkzrpxlkirglw";
    configurePhase = ''
    mkdir -p $out/per-session-${name}
    mkdir -p per-session-${name}

    ln -s ${components.file_open}/lib/libcomponent.so $out/per-session-${name}/${components.file_open.name}.so
    ln -s ${components.file_open}/lib/libcomponent.so per-session-${name}/${components.file_open.name}.so
    ln -s ${components.file_print}/lib/libcomponent.so $out/per-session-${name}/${components.file_print.name}.so
    ln -s ${components.file_print}/lib/libcomponent.so per-session-${name}/${components.file_print.name}.so
    ln -s ${components.development_fbp_parser_lexical}/lib/libcomponent.so $out/per-session-${name}/${components.development_fbp_parser_lexical.name}.so
    ln -s ${components.development_fbp_parser_lexical}/lib/libcomponent.so per-session-${name}/${components.development_fbp_parser_lexical.name}.so
    ln -s ${components.development_fbp_parser_semantic}/lib/libcomponent.so $out/per-session-${name}/${components.development_fbp_parser_semantic.name}.so
    ln -s ${components.development_fbp_parser_semantic}/lib/libcomponent.so per-session-${name}/${components.development_fbp_parser_semantic.name}.so
    ln -s ${components.development_fbp_parser_print_graph}/lib/libcomponent.so $out/per-session-${name}/${components.development_fbp_parser_print_graph.name}.so
    ln -s ${components.development_fbp_parser_print_graph}/lib/libcomponent.so per-session-${name}/${components.development_fbp_parser_print_graph.name}.so
    ln -s ${components.development_capnp_encode}/lib/libcomponent.so $out/per-session-${name}/${components.development_capnp_encode.name}.so
    ln -s ${components.development_capnp_encode}/lib/libcomponent.so per-session-${name}/${components.development_capnp_encode.name}.so
    ln -s ${components.development_fbp_fvm}/lib/libcomponent.so $out/per-session-${name}/${components.development_fbp_fvm.name}.so
    ln -s ${components.development_fbp_fvm}/lib/libcomponent.so per-session-${name}/${components.development_fbp_fvm.name}.so
    ln -s ${components.development_fbp_errors}/lib/libcomponent.so $out/per-session-${name}/${components.development_fbp_errors.name}.so
    ln -s ${components.development_fbp_errors}/lib/libcomponent.so per-session-${name}/${components.development_fbp_errors.name}.so
    ln -s ${components.development_fbp_scheduler}/lib/libcomponent.so $out/per-session-${name}/${components.development_fbp_scheduler.name}.so
    ln -s ${components.development_fbp_scheduler}/lib/libcomponent.so per-session-${name}/${components.development_fbp_scheduler.name}.so
    ln -s ${support.component_lookup}/lib/libcomponent.so $out/per-session-${name}/${support.component_lookup.name}.so
    ln -s ${support.component_lookup}/lib/libcomponent.so per-session-${name}/${support.component_lookup.name}.so
    ln -s ${support.contract_lookup}/lib/libcomponent.so $out/per-session-${name}/${support.contract_lookup.name}.so
    ln -s ${support.contract_lookup}/lib/libcomponent.so per-session-${name}/${support.contract_lookup.name}.so

    ${pkgs.stdenv.lib.concatMapStringsSep "\n"
      (dep: "ln -sf ${dep.outPath}/lib/libcomponent.so $out/per-session-${name}/${dep.name}.so;")
      (pkgs.stdenv.lib.flatten subnetDeps)}

    ln -s ${pkgs.capnproto}/bin/capnp $out/per-session-${name}/capnp

    substituteInPlace src/lib.rs --replace "path_capnp.rs" "${contracts.path}/src/contract_capnp.rs"
    substituteInPlace src/lib.rs --replace "per-session" "per-session-${name}"
    substituteInPlace Cargo.toml --replace "fvm" "${name}"
    substituteInPlace src/main.rs --replace "fvm" "${name}"

    '';

    meta = with pkgs.stdenv.lib; {
      description = "Fractalide Virtual Machine";
      homepage = https://github.com/fractalide/fractalide;
      license = with licenses; [ agpl3Plus ];
      maintainers = with support.upkeepers; [ dmichiels sjmackenzie ];
    };
  };
  in
fvm
