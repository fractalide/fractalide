{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xb15de9c2c13e4bb2;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct CoreActionAdd {
           name @0 :PrimText.PrimText;
           comp @1 :PrimText.PrimText;
    }
  '';
}
