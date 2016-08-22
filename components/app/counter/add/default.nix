{ stdenv, buildFractalideComponent, genName, upkeepers
  , app_counter
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ app_counter ];
  depsSha256 = "07wyl35nnbgjrrfr199znqakksc8xxp2i8gvq1ksp4ak7p227y0n";

  meta = with stdenv.lib; {
    description = "Component: increase by one the number";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
