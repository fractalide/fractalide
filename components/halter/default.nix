{ stdenv, buildFractalideComponent, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "01nxcbqscx5yrrh9iy2f6gy87y728bxikmcd391ig6x8zmxis7fg";

  meta = with stdenv.lib; {
    description = "Component: Keep the graph running";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
