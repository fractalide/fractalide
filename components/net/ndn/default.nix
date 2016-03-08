{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn_face
  , net_ndn_cs
  , net_ndn_fib
  , net_ndn_pit
  , drop_ip
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
// Interests flow upstream towards data creator
// Data flows downstream towards intested actor

  interest => lookup_interest cs(${net_ndn_cs}) interest_hit => data
  cs() interest_miss -> lookup_interest pit(${net_ndn_pit}) interest_hit -> new_face face(${net_ndn_face})
  pit() interest_miss -> lookup_interest fib(${net_ndn_fib}) interest_miss -> drop drop_ip(${drop_ip})
  fib() interest_hit[0] -> create_entry pit()
  fib() interest_hit[1] => forward

  data => lookup_data pit() data_miss -> drop drop_ip()
  pit() data_hit[0] -> delete_entry pit()
  pit() data_hit[1] -> cache_data cs()
  pit() data_hit[2] => forward
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
