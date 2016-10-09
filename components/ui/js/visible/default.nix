{ stdenv, buildFractalideComponent, genName, upkeepers
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ js_create ];
  depsSha256 = "07sj3sh2d8nqp1x3sn4hhbfbckw2mly3k8fjxip3hdf7rr8zb0l4";
  meta = with stdenv.lib; {
    description = "Component: draw a place holder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
