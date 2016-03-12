{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn_faces
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

  interest => app_interest faces(${net_ndn_faces}) interest ->
    lookup_interest cs(${net_ndn_cs}) interest_hit -> forward faces() out => data

  cs() interest_miss -> lookup_interest pit(${net_ndn_pit}) interest_miss ->
     lookup_interest fib(${net_ndn_fib}) interest_miss -> drop drop_ip(${drop_ip})

  fib() interest_hit[0] -> create_entry pit()
  fib() interest_hit[1] -> forward faces()

  data => lookup_data pit() data_miss -> drop drop_ip()
  pit() data_hit[0] -> delete_entry pit()
  pit() data_hit[1] -> cache_data cs()
  pit() data_hit[2]  -> forward faces()
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
