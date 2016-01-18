{ pkgs, stdenv ? pkgs.stdenv
  , fetchFromGitHub ? support.fetchFromGitHub
  , rustUnstable ? support.rustUnstable
  , rustRegistry ? support.rustRegistry
  , buildRustPackage ? support.buildRustPackage
  , support, components, contracts }:

  with rustUnstable rustRegistry;

  buildRustPackage rec {
    name = "fvm";
    src = ./.;
    depsSha256 = "0w8b6mldsxqn807sb232m2xb7d9vzlyh5f8rqm6vf5555by3fzw7";

    configurePhase = ''
    substituteInPlace src/main.rs \
    --replace "path_capnp.rs" "${builtins.head (contracts.path)}/src/contract_capnp.rs" \
    --replace "file_open.so" "${components.file_open}/lib/libcomponent.so" \
    --replace "file_print.so" "${components.file_print}/lib/libcomponent.so" \
    --replace "development_parser_fbp_lexical.so" "${components.development_parser_fbp_lexical}/lib/libcomponent.so" \
    --replace "development_parser_fbp_semantic.so" "${components.development_parser_fbp_semantic}/lib/libcomponent.so" \
    --replace "development_parser_fbp_print_graph.so" "${components.development_parser_fbp_print_graph}/lib/libcomponent.so" \
    --replace "development_fvm.so" "${components.development_fvm}/lib/libcomponent.so" \
    '';

    meta = with stdenv.lib; {
      description = "Fractalide Virtual Machine";
      homepage = https://github.com/fractalide/fractalide;
      license = with licenses; [ mit ];
      maintainers = [ maintainers.sjmackenzie ];
    };
  }

