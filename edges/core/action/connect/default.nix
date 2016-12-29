{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0x8067311a5b6027d2;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct CoreActionConnect {
           oName @0 :PrimText.PrimText;
           oPort @1 :PrimText.PrimText;
           oSelection @2 :PrimText.PrimText;
           iName @3 :PrimText.PrimText;
           iPort @4 :PrimText.PrimText;
           iSelection @5 :PrimText.PrimText;
    }
  '';
}
