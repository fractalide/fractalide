{ stdenv, buildFractalideComponent, genName, upkeepers
  , maths_number
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_number ];
  depsSha256 = "14hvw3mysbwxv31xgckdbk7rgfva4b3ajy4ic1l2jpd5vm07y4k5";

  meta = with stdenv.lib; {
    description = "Component: Adds all inputs together";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/add;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
