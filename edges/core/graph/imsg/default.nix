{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0x95d1db14d7b85555;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct CoreGraphImsg {
           imsg @0 :PrimText.PrimText;
           comp @1 :PrimText.PrimText;
           port @2 :PrimText.PrimText;
           selection @3 :PrimText.PrimText;
    }

  '';
}
