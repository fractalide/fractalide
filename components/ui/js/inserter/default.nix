{ stdenv, buildFractalideComponent, genName, upkeepers
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ js_create ];
  depsSha256 = "1kli7pd0xsdbqdldxj9vzzcgh1mqpjpd2y3ggjfys75203n7bwsa";

  meta = with stdenv.lib; {
    description = "Component: manage the inside of a js block";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
