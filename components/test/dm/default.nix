{ stdenv, buildFractalideSubnet, upkeepers
  , maths_boolean_not
  , maths_boolean_print
  # contracts
  , maths_boolean
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   '${maths_boolean}:(boolean=false)' -> input not(${maths_boolean_not}) output -> input disp(${maths_boolean_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: testing file for denis";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/test/dm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
