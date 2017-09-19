{ buffet }:

{ name, edges ? [] } @ args:
let
  stdenv = buffet.pkgs.stdenv;
  compName = name + "__rs_edges";
in
stdenv.mkDerivation (args // rec {
  name = compName;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    echo "// This file is generated don't edit it." >> $out/edges.rs
    echo "" >> $out/edges.rs
    for e in $edges; do
      echo "// Start of $e" >> $out/edges.rs
      cat $e/edge.rs >> $out/edges.rs
      echo "// End of   $e" >> $out/edges.rs
      echo "" >> $out/edges.rs
    done
  '';

})
