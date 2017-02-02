{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ kv_key_t_val_t ];
  schema = with edges; ''
    struct KvListKeyTValT {
      list @0 : List(KvKeyTValT);
    }
  '';
}
