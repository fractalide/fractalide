{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xa3cd85e8335a7357;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct PrimListText {
            list @0 :List(PrimText.PrimText);
    }
  '';
}
