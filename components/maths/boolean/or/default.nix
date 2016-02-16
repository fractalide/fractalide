{ stdenv, buildFractalideSubnet, upkeepers, maths_boolean_not, maths_boolean_and, ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
  a => input not2(${maths_boolean_not}) output -> b and(${maths_boolean_and})
  b => input not1(${maths_boolean_not}) output -> a and() output -> input not3(${maths_boolean_not}) output => output
  '';

  meta = with stdenv.lib; {
    description = "Subnet: OR logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/or;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
