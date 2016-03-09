{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn
  , net_ndn_print_interest
  , ...}:

  buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   'net_ndn_interest:(name="the name", nonce=0100)' -> interest ndn(${net_ndn}) data -> input disp(${net_ndn_print_interest})
   '';

   meta = with stdenv.lib; {
    description = "Subnet: testing file for sjm";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/test/sjm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
