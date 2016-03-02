{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , SDL2
  , freetype
  , ...}:

  buildFractalideComponent rec {
    name = genName ./.;
    src = ./.;
    filteredContracts = filterContracts ["ui_conrod"];
    depsSha256 = "1qq4lh82mr7nv50q3dcdd6j8k77z9afkz2pjjpmb7gldf477mv0j";
    buildInputs = [ freetype SDL2 ];

    meta = with stdenv.lib; {
      description = "Component: draw a conrod window";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
