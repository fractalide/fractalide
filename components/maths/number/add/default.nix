{ stdenv, buildFractalideComponent, genName, upkeepers
  , maths_number
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_number ];
  depsSha256 = "0aanby9la2j9mffmrmlny1319i0150nk9i2rcyg5iv7zf1riswdz";

  meta = with stdenv.lib; {
    description = "Component: Adds all inputs together";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/add;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
