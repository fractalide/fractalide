{ stdenv, buildFractalideSubnet, upkeepers, maths_boolean_nand, maths_boolean_not, ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
  a => a nand(${maths_boolean_nand}) output -> input not(${maths_boolean_not}) output => output
  b => b nand()
  '';

  meta = with stdenv.lib; {
    description = "Subnet: AND logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/and;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
