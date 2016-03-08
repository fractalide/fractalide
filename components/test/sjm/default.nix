{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn
  , maths_boolean_print
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   'maths_boolean:(boolean=false)' -> interest ndn(${net_ndn}) data -> input disp(${maths_boolean_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: testing file for sjm";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
