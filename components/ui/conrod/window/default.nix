{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , mesa
  , freeglut
  , xlibs
  , SDL2
  , freetype
  , ...}:
  let
  tls-freetype = stdenv.lib.overrideDerivation freetype (oldAttrs : {
    NIX_CFLAGS_COMPILE = oldAttrs.NIX_CFLAGS_COMPILE + " -fPIC -DPIC";
    });
  tls-freeglut = stdenv.lib.overrideDerivation freeglut (oldAttrs : {
    NIX_CFLAGS_COMPILE = " -fPIC -DPIC";
    });
  tls-SDL2 = stdenv.lib.overrideDerivation SDL2 (oldAttrs : {
    NIX_CFLAGS_COMPILE = " -fPIC -DPIC";
    });
  tls-mesa = stdenv.lib.overrideDerivation mesa (oldAttrs : {
    NIX_CFLAGS_COMPILE = " -fPIC -DPIC";
    });
  tls-libX11 = stdenv.lib.overrideDerivation xlibs.libX11 (oldAttrs : {
    NIX_CFLAGS_COMPILE = " -fPIC -DPIC";
    });
  tls-libXcursor = stdenv.lib.overrideDerivation xlibs.libXcursor (oldAttrs : {
    NIX_CFLAGS_COMPILE = " -fPIC -DPIC";
    });
  tls-libXxf86vm = stdenv.lib.overrideDerivation xlibs.libXxf86vm (oldAttrs : {
    NIX_CFLAGS_COMPILE = " -fPIC -DPIC";
    });
  tls-libXi = stdenv.lib.overrideDerivation xlibs.libXi (oldAttrs : {
    NIX_CFLAGS_COMPILE =  " -fPIC -DPIC";
    });
  in
  buildFractalideComponent rec {
    name = genName ./.;
    src = ./.;
    filteredContracts = filterContracts ["ui_conrod"];
    depsSha256 = "1qq4lh82mr7nv50q3dcdd6j8k77z9afkz2pjjpmb7gldf477mv0j";
    patchElfDeps = with xlibs; ''
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $out/lib/libcomponent.so
      patchelf --set-rpath ${tls-mesa}/lib:${tls-freeglut}/lib:${tls-freetype}/lib:${tls-SDL2}/lib $out/lib/libcomponent.so
    '';
    propagatedBuildInputs = with xlibs; [
    tls-mesa tls-freeglut tls-freetype tls-SDL2

    # The following libs ought to be propagated build inputs of Mesa.
    tls-libXi libSM libXmu libXext tls-libX11
  ];

    meta = with stdenv.lib; {
      description = "Component: draw a conrod window";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
