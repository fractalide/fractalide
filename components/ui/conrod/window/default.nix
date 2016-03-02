{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , SDL2
  , freetype
  , ...}:

  buildFractalideComponent rec {
    name = genName ./.;
    src = ./.;
    filteredContracts = filterContracts ["ui_conrod"];
  depsSha256 = "1zxc6f5mz45db2wrl4ldnggjigbljr7xys17i7d8vwdyzsbik30y";
    buildInputs = [ freetype SDL2 ];

    meta = with stdenv.lib; {
      description = "Component: draw a conrod window";
      homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
      license = with licenses; [ mpl20 ];
      maintainers = with upkeepers; [ dmichiels sjmackenzie];
    };
  }
