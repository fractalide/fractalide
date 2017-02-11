{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ PrimText ];
  schema = with edges; ''
    struct PrimListText {
            list @0 :List(PrimText);
    }
  '';
}
