{ stdenv, buildFractalideComponent, maths_boolean, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_boolean ];
  depsSha256 = "1yhjgmp7da6zfan6a92kzbl5yj5r65lwnbhjgja1nsgab19jy1is";

  meta = with stdenv.lib; {
    description = "Component: Print the content of the contract maths_boolean";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
