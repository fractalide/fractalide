{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xebdf9dd03f09e40c;

    struct PrimI16 {
            i16 @0 :Int16;
    }
  '';
}
