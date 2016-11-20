{ stdenv, buildFractalideComponent, maths_boolean, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_boolean ];
  depsSha256 = "0pzvnvhmzv1bbp5gfgmak3bsizhszw4bal0vaz30xmmd5yx5ciqj";

  meta = with stdenv.lib; {
    description = "Component: Print the content of the contract maths_boolean";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
