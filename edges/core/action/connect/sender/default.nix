{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xe15d96eb26e71b90;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct CoreActionConnectSender {
           name @0 :PrimText.PrimText;
           port @1 :PrimText.PrimText;
           selection @2 :PrimText.PrimText;
           output @3 :PrimText.PrimText;
    }

  '';
}
