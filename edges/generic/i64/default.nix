{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xcd25af61b5d6c76b;

    struct GenericI64 {
            number @0 :Int64;
    }
  '';
}
