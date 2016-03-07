{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn
  , maths_boolean_print
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   'maths_boolean:(boolean=false)' -> interest ndn(${net_ndn}) data_found -> input disp(${maths_boolean_print})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: development testing file";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
