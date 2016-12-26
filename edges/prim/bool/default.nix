{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x94fa2d53ea744717;

    struct PrimBool {
            bool @0 :Bool;
    }
  '';
}
