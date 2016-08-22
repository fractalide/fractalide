{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text js_create ];
  depsSha256 = "07wyl35nnbgjrrfr199znqakksc8xxp2i8gvq1ksp4ak7p227y0n";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod text";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
