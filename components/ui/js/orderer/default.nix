{ stdenv, buildFractalideComponent, genName, upkeepers
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ js_create ];
  depsSha256 = "1g90kjxpymp3jhhps6jj7ys58ij69rsyalg6yhb6dbxn473f2c0i";

  meta = with stdenv.lib; {
    description = "Component: manage the inside of a js block";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
