{ stdenv, buildFractalideComponent, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "04vwjvkqgqhavkrjclnxyvd2mayk1x3r2xqqvk28i01y2v6qgygr";

  meta = with stdenv.lib; {
    description = "Component: Delay by 1 sec the IPs coming in";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
