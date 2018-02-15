{ stdenv }:
{ name,
  src,
  version,
  unifiedCapnpEdges,
  unifiedRustEdges,
  postInstall
}:
stdenv.mkDerivation {
  inherit unifiedRustEdges unifiedCapnpEdges postInstall;
  name = name + "__to_crate";
  crateName = name;
  version = version;
  src = src;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/src
    if [[ ! -z "$unifiedCapnpEdges" ]] ; then
      ln -s $unifiedCapnpEdges/edge_capnp.rs $out/src
    else
      touch $out/src/edge_capnp.rs
    fi
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
