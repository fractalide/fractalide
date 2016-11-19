{ stdenv, buildFractalideComponent, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "0w4dg60qpcgjmaraami2kf36rgnj4mvs9fv54n6dkx62ih26mpa7";

  meta = with stdenv.lib; {
    description = "Component: Keep the graph running";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
