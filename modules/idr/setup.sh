unset PATH
for p in $baseInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

IDRIS_I_PATHS=()

function preHook() {
  idris_version=$(idris --version)
  IDRIS_LIBRARY_PATH=$PWD/idris_libs
  mkdir -p $IDRIS_LIBRARY_PATH

  export IBCSUBDIR=$out/lib/$idris_version
  mkdir -p $IBCSUBDIR

  for ipkg in $propagatedBuildInputs; do
    ln -sf "$ipkg/lib/$idris_version"/* $IDRIS_LIBRARY_PATH
    ipkg_name=$(cat "$ipkg/lib/$idris_version/NAME")
    IDRIS_I_PATHS+=("$ipkg/lib/$idris_version/$ipkg_name")
  done
}

function unpackPhase() {
  local fn="$src"

  if [ -d "$fn" ]; then
      ipkg_name=$(echo -e "${unpackPhase}" | tr -d '[:space:]')
      if [ ! -z $ipkg_name ]; then
        cp -pr --reflink=auto "$fn/libs"/* .
      else
        cp -pr --reflink=auto "$fn"/* .
      fi
  else
      case "$fn" in
          *.tar.xz | *.tar.lzma)
              xz -d < "$fn" | tar xf -
              ;;
          *.tar | *.tar.* | *.tgz | *.tbz2)
              tar xf "$fn"
              ;;
          *)
              return 1
              ;;
      esac
  fi
}

function prePatch {
  if [ -e agent.ipkg ]; then
    substituteInPlace agent.ipkg --replace nix_replace_me $name
  fi
}

function postPatch {
  find . -type d -exec chmod 0755 {} \;
  find . -type f -exec chmod 0644 {} \;
  find . -name "*.ibc" -type f -exec chmod 0744 {} \;
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
    ipkg_name=($(grep -oP '^\s*package\s+([a-zA-Z][-_A-Za-z0-9]*)' $(echo *.ipkg)))
    echo "${ipkg_name[1]}" >> $IBCSUBDIR/NAME
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

function build() {
  genericBuild
  echo "^^^ You can safely ignore these errors. ^^^"
}

function setupIdris () {
  unique_libs=($(printf "%s\n" "${IDRIS_I_PATHS[@]}" | sort | uniq))
  idris_paths=()
  for path in "${unique_libs[@]}"; do
    idris_paths+=("-i $path")
  done
  idris_paths+=("-i $(pwd)/idris_libs")
  alias idris="idris ${idris_paths[@]}"
}

function run() {
  setupIdris
  /run/current-system/sw/bin/$1 $2
}
