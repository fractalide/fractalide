{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x87496148360d604f;

    struct PrimBool {
            bool @0 :Bool;
    }
  '';
}
