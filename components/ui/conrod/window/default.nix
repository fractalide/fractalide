{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , SDL2
  , freetype
  , ...}:

  buildFractalideComponent rec {
    name = genName ./.;
    src = ./.;
    filteredContracts = filterContracts ["ui_conrod"];
  depsSha256 = "1lri4ra9f7364jib0yqbdvpn1qckh7wqwgzc18g76vfzxn7b7jd1";
    buildInputs = [ freetype SDL2 ];

    meta = with stdenv.lib; {
      description = "Component: draw a conrod window";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
