{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x86b82a2fc79a7f6d;

    struct AppCounter {
      value @0 :Int64;
      delta @1 :Int64 = 1;
    }
  '';
}
