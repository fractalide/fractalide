{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn_face
  , net_ndn_cs
  , net_ndn_fib
  , net_ndn_pit
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
  // Interest arrives
  interest => new_interest face(${net_ndn_face}) name_registered -> find_data cs(${net_ndn_cs}) hit -> kill_face face() data_found => data_found
  cs() miss -> register_name pit(${net_ndn_pit}) new_interest -> forward fib(${net_ndn_fib})

  // Data arrives
  data => forward pit() deleted -> store cs()
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
