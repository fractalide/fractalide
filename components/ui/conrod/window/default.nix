{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , mesa
  , freeglut
  , xlibs
  , SDL2
  , freetype
  , ...}:

  buildFractalideComponent rec {
    name = genName ./.;
    src = ./.;
    filteredContracts = filterContracts ["ui_conrod"];
    depsSha256 = "1qq4lh82mr7nv50q3dcdd6j8k77z9afkz2pjjpmb7gldf477mv0j";
    patchElfDeps = with xlibs; ''
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $out/lib/libcomponent.so
      patchelf --set-rpath ${mesa}/lib:${freeglut}/lib:${freetype}/lib:${SDL2}/lib $out/lib/libcomponent.so
    '';
    propagatedBuildInputs = with xlibs; [
    mesa freeglut freetype SDL2

    # The following libs ought to be propagated build inputs of Mesa.
    libXi libSM libXmu libXext libX11
  ];

    meta = with stdenv.lib; {
      description = "Component: draw a conrod window";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
