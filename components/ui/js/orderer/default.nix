{ stdenv, buildFractalideComponent, genName, upkeepers
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ js_create ];
  depsSha256 = "05adywbmc5d5scinqx88wvr295d4rs3i0fbw9p6g84bhb336ax5s";

  meta = with stdenv.lib; {
    description = "Component: manage the inside of a js block";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
