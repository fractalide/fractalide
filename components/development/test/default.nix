{ stdenv, buildFractalideSubnet, upkeepers
  , maths_boolean_not
  , maths_boolean_print
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
'maths_boolean:(boolean=true)' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})
  '';

  meta = with stdenv.lib; {
    description = "Subnet: development testing file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
