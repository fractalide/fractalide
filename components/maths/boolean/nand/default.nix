{ stdenv, buildFractalideComponent, maths_boolean, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_boolean ];
  depsSha256 = "0pzvnvhmzv1bbp5gfgmak3bsizhszw4bal0vaz30xmmd5yx5ciqj";

  meta = with stdenv.lib; {
    description = "Component: NAND logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
