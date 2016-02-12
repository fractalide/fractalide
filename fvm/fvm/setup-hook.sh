addFractalLibPath() {
    addToSearchPath FRACTALLIB_PATH "$out/bin/fvm"
}

envHooks+=(addFractalLibPath)
