{ stdenv, buildFractalideSubnet, upkeepers, ip_clone, maths_boolean_nand, ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
  input => input clone(${ip_clone})
  clone() clone[1] -> a nand(${maths_boolean_nand}) output => output
  clone() clone[2] -> b nand()
  '';

  meta = with stdenv.lib; {
    description = "Subnet: NOT logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/not;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
