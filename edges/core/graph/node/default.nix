{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xf2f767a9f51e6095;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct CoreGraphNode {
           name @0 :PrimText.PrimText;
           sort @1 :PrimText.PrimText;
    }

  '';
}
