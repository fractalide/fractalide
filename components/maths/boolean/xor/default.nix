{ stdenv, buildFractalideSubnet, upkeepers, ...}:

buildFractalideSubnet rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Subnet: XOR logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/xor;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
