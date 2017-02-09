{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct NetProtocolDomainPort {
           protocol @0 :Text;
           domain @1 :Text;
           port @2 :UInt32;
    }
  '';
}
