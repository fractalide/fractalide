{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , mesa
  , xlibs
  , SDL2
  , freetype
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["ui_conrod"];
  depsSha256 = "0vgh9kanrn0rc7zrb05lckayddj8yiy93134ay3bbkdw94rkz7kb";

  buildInputs = [ freetype SDL2 ];
  LD_LIBRARY_PATH = with xlibs; "${mesa}/lib:${libX11}/lib:${libXcursor}/lib:${libXxf86vm}/lib:${libXi}/lib:${SDL2}/lib";
  
  meta = with stdenv.lib; {
    description = "Component: draw a conrod window";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
