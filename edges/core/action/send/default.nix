{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xeaa980bee40312b8;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct CoreActionSend {
           comp @0 :PrimText.PrimText;
           port @1 :PrimText.PrimText;
           selection @2 :PrimText.PrimText;
    }
  '';
}
