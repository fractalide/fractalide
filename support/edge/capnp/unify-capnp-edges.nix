{ buffet }:

{ name, edges ? [], target } @ args:
let
  stdenv = buffet.pkgs.stdenv;
  capnproto = buffet.pkgs.capnproto;
  compName = name + "_schema";
  capnpcPlugins = import ./capnpcPlugins { inherit buffet; };
in
stdenv.mkDerivation (args // rec {
  name = compName;
  phases = [ "buildPhase" "installPhase" ];
  buildPhase = ''
    ${ if edges != [] then ''
      local propagated
      for i in $edges; do
        findInputs $i propagated propagated-build-inputs
      done
      unique_propagated=($(printf "%s\n" "''${propagated[@]}" | sort -u))
      local propagated1
      for i in ''${unique_propagated[@]}; do
        propagated1="$propagated1 $i/src/edge.capnp"
      done
      for i in $propagated1; do
        cat $i >> edge.capnp
      done
      if [ -f edge.capnp ]; then
        # must refactor the below line, it introduces non-determinism; why doesn't md5sum work!?
        echo -e "$(${capnproto}/bin/capnpc -i);\n\n$(cat edge.capnp)" > edge.capnp
        ${
          if target == "capnp" then ''
          ''
          else if target == "rs" then ''
            ${capnproto}/bin/capnp compile -o${capnpcPlugins.rs}/bin/capnpc_rust edge.capnp
          ''
          else ''
            echo "Unknown capnproto compiler plugin called."
            exit 1
          ''
        }
      fi
    '' else ""
    }
  '';

  installPhase = ''
    mkdir -p $out
    ${
      if target == "capnp" then ''
        cp edge.capnp $out/edge.capnp
      ''
      else if target == "rs" then ''
        if [ -f edge_capnp.rs ]; then
          cp edge.capnp $out/edge.capnp
          cp edge_capnp.rs $out/edge_capnp.rs
        else
          touch $out/edge_capnp.rs
        fi
      ''
      else ""
    }
  '';

})
