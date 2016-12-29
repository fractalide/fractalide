{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xddd64d3b7f6348fe;

    struct PrimI32 {
            i32 @0 :Int32;
    }
  '';
}
