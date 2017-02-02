{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    struct PrimBool {
            bool @0 :Bool;
    }
  '';
}
