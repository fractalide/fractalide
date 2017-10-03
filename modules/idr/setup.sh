unset PATH
for p in $baseInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function preHook() {
  export IDRIS_LIBRARY_PATH=$PWD/libs
  mkdir -p $IDRIS_LIBRARY_PATH

  idris_version=$(idris --version)
  export IBCSUBDIR=$out/lib/$idris_version
  mkdir -p $IBCSUBDIR

  for ipkg in $propagatedBuildInputs; do
    ln -sf $ipkg/lib/$idris_version/* $IDRIS_LIBRARY_PATH
  done
}

stripHash() {
    local strippedName
    # On separate line for `set -e`
    strippedName="$(basename "$1")"
    if echo "$strippedName" | grep -q '^[a-z0-9]\{32\}-'; then
        echo "$strippedName" | cut -c34-
    else
        echo "$strippedName"
    fi
}

function unpackPhase() {
  local fn="$src"
  if [ -d "$fn" ]; then
      # We can't preserve hardlinks because they may have been
      # introduced by store optimization, which might break things
      # in the build.
      cp -pr --reflink=auto "$fn"/* .
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
}

# used in build-builtin-package, only for builtin packages otherwise it's ""
function postUnpack () {
  if [ ! -z $postUnpack ]; then
    cd idris*/libs/$postUnpack
  fi
}

function prePatch {
  if [ -e agent.ipkg ]; then
    substituteInPlace agent.ipkg --replace nix_replace_me $name
  fi
}
# used in build-builtin-package, only for builtin packages otherwise it's ""
function postPatch {
  if [ ! -z $postPatch ]; then
    ipkg_name=$(echo -e "${postPatch}.ipkg" | tr -d '[:space:]')
    sed -i $ipkg_name -e "/^opts/ s|-i \\.\\./|-i $IDRIS_LIBRARY_PATH/|g"
  fi
}

function buildPhase() {
  if [ ! -z $unifiedIdrisEdges ]; then
    "ln -s $unifiedIdrisEdges/edges.idr Edges.idr"
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
  postUnpack
  prePatch
  postPatch
  buildPhase
  checkPhase
  installPhase
  fixupPhase
}
