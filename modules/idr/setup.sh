unset PATH
for p in $baseInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function preHook() {
  idris_version=$(idris --version)
  export IDRIS_LIBRARY_PATH=$PWD/idris_libs
  mkdir -p $IDRIS_LIBRARY_PATH

  export IBCSUBDIR=$out/lib/$idris_version
  mkdir -p $IBCSUBDIR

  for ipkg in $propagatedBuildInputs; do
    ln -sf "$ipkg/lib/$idris_version"/* $IDRIS_LIBRARY_PATH
  done
}

function unpackPhase() {
  local fn="$src"

  if [ -d "$fn" ]; then
      ipkg_name=$(echo -e "${unpackPhase}" | tr -d '[:space:]')
      # We can't preserve hardlinks because they may have been
      # introduced by store optimization, which might break things
      # in the build.
      if [ ! -z $ipkg_name ]; then
        cp -pr --reflink=auto "$fn/libs"/* .
      else
        cp -pr --reflink=auto "$fn"/* .
      fi
  else
      case "$fn" in
          *.tar.xz | *.tar.lzma)
              # Don't rely on tar knowing about .xz.
              xz -d < "$fn" | tar xf -
              ;;
          *.tar | *.tar.* | *.tgz | *.tbz2)
              # GNU tar can automatically select the decompression method
              # (info "(tar) gzip").
              tar xf "$fn"
              ;;
          *)
              return 1
              ;;
      esac
  fi
  chmod -R 754 .
}

function prePatch {
  if [ -e agent.ipkg ]; then
    substituteInPlace agent.ipkg --replace nix_replace_me $name
  fi
}

function postPatch {
  if [ ! -z $postPatch ]; then
    ipkg_path=$(echo -e "$postPatch/$postPatch.ipkg" | tr -d '[:space:]')
    sed -i $ipkg_path -e "/^opts/ s|-i \\.\\./|-i $IDRIS_LIBRARY_PATH/|g"
  fi
}

function buildPhase() {
  if [ ! -z $buildPhase ]; then
    ipkg_path="$buildPhase"
    cd $ipkg_path
  fi
  if [ ! -z $unifiedIdrisEdges ]; then
    ln -s $unifiedIdrisEdges/edges.idr Edges.idr
  fi
  idris --build *.ipkg
}

function checkPhase() {
  if grep -q test *.ipkg; then
    idris --testpkg *.ipkg
  fi
}

function installPhase {
  if [ -a fvm ]; then
    cp fvm $out/
  else
    idris --install *.ipkg --ibcsubdir $IBCSUBDIR
    #cp --parents -r *.idr $IBCSUBDIR/*/
  fi
}

function fixupPhase() {
  find $out -type f -exec patchelf --shrink-rpath '{}' \; -exec strip '{}' \; 2>/dev/null
}

function genericBuild() {
  preHook
  unpackPhase
  prePatch
  postPatch
  buildPhase
  checkPhase
  installPhase
  fixupPhase
}
