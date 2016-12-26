{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ key_t_val_t ];
  schema = with edges; ''
    @0xee03b0ceac365981;

    using KeyTValT = import "${key_t_val_t}/src/edge.capnp";

    struct ListKeyTValT {
      list @0 : List(KeyTValT.KeyTValT);
    }
  '';
}
