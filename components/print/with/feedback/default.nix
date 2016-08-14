{ stdenv, buildFractalideComponent, genName, upkeepers
  , path
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ path value_string ];
  depsSha256 = "0s0zgn8yrkiqk2ixlbnx4i2pmqzc7ihgc0bjwlbmylqjcsxgg1x6";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
