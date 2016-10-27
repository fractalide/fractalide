{ stdenv, buildFractalideComponent, maths_boolean, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_boolean ];
  depsSha256 = "109fdnl3a5nl2bwmc13mlmvx1m02d9nc12k9amy4v53ajqasg4m6";

  meta = with stdenv.lib; {
    description = "Component: NAND logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
