{ stdenv }:
{ name,
  src,
  version,
  unifiedRustEdges,
  postInstall
}:
stdenv.mkDerivation {
  inherit unifiedRustEdges postInstall;
  name = name + "__to_crate";
  crateName = name;
  version = version;
  src = src;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/src
    if [[ ! -z "$unifiedRustEdges" ]] ; then
      ln -s $unifiedRustEdges/edges.rs $out/src
    else
      touch $out/src/edges.rs
    fi
    if [ -e "$src/lib.rs" ] ; then
      ln -s $src/lib.rs $out/src
    else
      runHook postInstall
    fi
  '';

}
