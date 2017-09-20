{ buffet }:

{ name, edges ? [] } @ args:
let
  stdenv = buffet.pkgs.stdenv;
  compName = name + "__idr_edges";
in
stdenv.mkDerivation (args // rec {
  name = compName;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    echo "-- This file is generated don't edit it." >> $out/edges.idr
    echo "" >> $out/edges.idr
    for e in $edges; do
      echo "-- Start of $e" >> $out/edges.idr
      cat $e/edge.idr >> $out/edges.idr
      echo "-- End of   $e" >> $out/edges.idr
      echo "" >> $out/edges.idr
    done
  '';

})
