{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [];
  schema = with edges.capnp; ''
    struct NetProtocolDomainPort {
           protocol @0 :Text;
           domain @1 :Text;
           port @2 :UInt32;
    }
  '';
}
