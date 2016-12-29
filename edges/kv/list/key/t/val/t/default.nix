{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ kv_key_t_val_t ];
  schema = with edges; ''
    @0xee03b0ceac365981;

    using KvKeyTValT = import "${kv_key_t_val_t}/src/edge.capnp";

    struct KvListKeyTValT {
      list @0 : List(KvKeyTValT.KvKeyTValT);
    }
  '';
}
