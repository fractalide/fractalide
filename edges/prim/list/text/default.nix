{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    struct PrimListText {
            list @0 :List(PrimText);
    }
  '';
}
