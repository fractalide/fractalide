{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0x81458f10b34067d8;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct CoreGraphExt {
           name @0 :PrimText.PrimText;
           comp @1 :PrimText.PrimText;
           port @2 :PrimText.PrimText;
           selection @3 :PrimText.PrimText;
    }
  '';
}
