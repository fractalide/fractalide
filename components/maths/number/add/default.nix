{ stdenv, buildFractalideComponent, genName, upkeepers
  , maths_number
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_number ];
  depsSha256 = "0m7kb3zbnv7f4zkcp0m2yyx1yd56k7j4dfgyda0qbyhl7s2yq4zy";

  meta = with stdenv.lib; {
    description = "Component: Adds all inputs together";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/add;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
