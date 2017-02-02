{lib, stdenv, capnproto, capnpc-rust}:

{ name, edges ? [], target } @ args:

let
  schemaName = name + "-schema";
in stdenv.mkDerivation (args // rec {
  name = schemaName;
  phases = [ "buildPhase" "installPhase" ];
  buildPhase = ''
    touch edge_capnp.rs
    ${ if edges != [] then ''
      propagated=""
      for i in $edges; do
        findInputs $i propagated propagated-build-inputs
      done
      propagated1=""
      for i in $propagated; do
        propagated1="$propagated1 $i/src/edge.capnp"
      done
      for i in $propagated1; do
        cat $i >> edge.capnp
      done
      if [ -f edge.capnp ]; then
        # must refactor the below line, it introduces non-determinism; why doesn't md5sum work!?
        echo -e "$(${capnproto}/bin/capnpc -i);\n\n$(cat edge.capnp)" > edge.capnp
        ${ if target == "rs" then ''
          ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust edge.capnp -I "/"
        '' else ""
        }
      fi
    '' else ""
    }
  '';

  installPhase = ''
    mkdir -p $out
    cp edge_capnp.rs $out/edge_capnp.rs
    if [ -f edge.capnp ]; then
      cp edge.capnp $out/edge.capnp
    fi
  '';

})
