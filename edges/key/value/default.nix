{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x8a258ed34eb0c0bb;

    struct KeyValue {
        key @0 :Text;
        value @1 :Int64;
    }
  '';
}
