unset PATH
for p in $baseInputs $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function preHook() {
  export IDRIS_LIBRARY_PATH=$PWD/libs
  mkdir -p $IDRIS_LIBRARY_PATH

  # Library install path
  idris_version=$(idris --version)
  export IBCSUBDIR=$out/lib/$idris_version
  mkdir -p $IBCSUBDIR

  addIdrisLibs () {
    if [ -d $1/lib/$idris_version ]; then
      ln -sf $1/lib/$idris_version/* $IDRIS_LIBRARY_PATH
    fi
  }

  envHooks+=(addIdrisLibs)
}

function unpackPhase() {
  # revamp to support src directories and compressed files
  tar xzf $src
  # mv idris*/* .
  # cp $src/* -r .
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
  echo ------------
  echo $IDRIS_LIBRARY_PATH
  ls $IDRIS_LIBRARY_PATH/* #<--- fails here due to preHook not being executed.
  echo ------------
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
