{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn_router_faces
  , net_ndn_router_cs
  , net_ndn_router_fib
  , net_ndn_router_pit
  , drop_ip
  # contracts
  , protocol_domain_port
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
// https://www.cs.arizona.edu/~yic/paper/dissertation.pdf

// Content Store
// CS = caches Data packets.
//   ,-------------------------------------------,
//   | Name         |         Data               |
//   |-------------------------------------------|
//   | /foo/bar/1  |          .....              |
//   '-------------------------------------------'

// Pending Interest Table
// PIT = the PIT stores all Interest packets that have been forwarded but not yet satisfied.
//   Each PIT entry records the name and incoming interface(s) of the Interest(s), as well
//   as the outgoing interface(s) to which the Interest(s) has been forwarded
//
//   New Interest
// ,------------------------------------------------------------------------,
// |   Name   |Nonces|Incoming |Receive    |outgoing|Send       |Retry      |
// |          |      |interface|Time       |interfac|time       |timeout    |
// |----------+------+---------+-----------+--------+-----------+-----------|
// |/foo/bar/1|246234|   1     |05/20/2014 |    3   |05/20/2014 |05/20/2014 |
// |          |      |         |13:21:43.02|        |13:21:43.02|13:21:43.07|
// '------------------------------------------------------------------------'
//
// Suppressed Subsequent Interest
// ,-------------------------------------------------------------------------,
// |   Name   |Nonces |Incoming |Receive    |outgoing|Send       |Retry      |
// |          |       |Interface|Time       |interfac|time       |timeout    |
// |----------+-------+---------+-----------+--------+-----------+-----------|
// |/foo/bar/1|246234 |   1     |05/20/2014 |   3    |           |           |
// |          |       |         |13:21:43.02|        |05/20/2014 |05/20/2014 |
// |          |-------+---------+-----------|        |13:21:43.02|13:21:43.07|
// |          |1532689|   4     |05/20/2014 |        |           |           |
// |          |       |         |13:21:43.04|        |           |           |
// '-------------------------------------------------------------------------'
//
//   Forwarded Subsequent Interest
// ,-------------------------------------------------------------------------,
// |  Name    | Nonces|Incoming |Receive    |outgoing|Send time  |Retry      |
// |          |       |Interface|Time       |interfac|           |timeout    |
// |----------+-------+---------+-----------+--------+-----------+-----------|
// |/foo/bar/1| 246234|    1    |05/20/2014 |   3    |05/20/2014 |05/20/2014 |
// |          |       |         |13:21:43.02|        |13:21:43.02|13:21:43.07|
// |          |-------+---------+-----------+--------+-----------+-----------|
// |          |1532689|    4    |05/20/2014 |   2    |05/20/2014 |05/20/2014 |
// |          |       |         |13:21:44.01|        |13:21:44.01|13:21:44.09|
// '-------------------------------------------------------------------------'

// Forwarding Information Base
// FIB = stores forwarding rules.
//   ,----------------------------------------------------,
//   |Prefix|Stale Time|_____Interfaces___________________|
//   |      |          | ID | Routing   |RTT |RTO |Status |
//   |      |          |    | Preference|    |    |       |
//   |------+----------+----+-----------+----+----+-------|
//   |/foo  |   120    | 3  |  50       |45ms|50ms|Green  |
//   |      |          | 2  |  70       |60ms|80ms|Yellow |
//   |      |          | 4  |  100      |N/A |N/A |Yellow |  <-- not used
//   |      |          | 1  |  110      |N/A |N/A |Yellow |  <-- not used
//   '----------------------------------------------------'

// Interest and Data Processing in NDN
// Interests flow upstream towards data producer
// Data flows downstream towards intested actor
//         ,---------------------------------------------------,
//    Data |                add interface           drop NACK  |
//         |                to PIT entry          and Interest |
//     <---|--------,                ^                  ^      |
//         |        | hit            | hit              | miss |
//         |   ,---------,       ,--------,         ,-----,    |
// Interest|   |         |  miss |        |  miss   |     | hit|
// -->-----|-->|    CS   |-----> |        |-------->| FIB |----+---->
//         |   |         |       |        |   \     |     |    |  forward
//         |   '---------'       |  PIT   |    |    '-----'    |
//         |        ^            |        |   \/               |
//         |        |  cache     |        |   create PIT       |
// forward |         \           |        |     entry          |   Data
//   <-----|---------------------|        |<-------------------|-----<--
//         |           / hit     '--------'                    |
//         |          |               |  miss                  |
//         |          \/             \/                        |
//         | delete PIT entry  discard Data                    |
//         '---------------------------------------------------'
//    <--  DOWNSTREAM                                   UPSTREAM -->
//                  hit = lookup hit - miss = lookup miss

'${protocol_domain_port}:(protocol="ws://",domain="127.0.0.1",port=8888)' -> start faces(${net_ndn_router_faces})
'${protocol_domain_port}:(protocol="ws://",domain="127.0.0.1",port=8888)' -> option faces(${net_ndn_router_faces})

// Interest path
  faces(${net_ndn_router_faces}) interest -> lookup_interest cs(${net_ndn_router_cs}) interest_hit ->
      forward_interest faces()
  cs() interest_miss -> lookup_interest pit(${net_ndn_router_pit}) interest_miss -> // also create PIT entry
      lookup_interest fib(${net_ndn_router_fib}) // if fib() interest_miss then drop NACK and Interest
  // if pit() interest_hit add interface to pit entry
  fib() interest_hit -> forward_interest faces()

// Data path
  faces() data_arrived -> lookup_data pit() // if data_miss -> drop drop_ip()
  pit() data_hit[0] -> cache_data cs()
  pit() data_hit[1] -> forward_data faces()
  // if pit() data_hit[_] then delete PIT entry
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn_router; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
