{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text prim_void ];
  schema = with edges; ''
    @0x9c951b3548fca4c2;

    using PrimText = import "${prim_text}/src/edge.capnp";
    using PrimVoid = import "${prim_void}/src/edge.capnp";

    struct CoreLexical {
      union {
        start @0 :PrimText.PrimText;
        end @1 :PrimText.PrimText;
        notFound @2 :PrimText.PrimText;
        token :union {
          bind @3 :PrimVoid.PrimVoid;
          external @4 :PrimVoid.PrimVoid;
          comp :group {
            name @5 :PrimText.PrimText;
            sort @6 :PrimText.PrimText;
          }
          port :group {
            name @7 :PrimText.PrimText;
            selection @8 :PrimText.PrimText;
          }
          imsg @9 :PrimText.PrimText;
          break @10 :PrimVoid.PrimVoid;
        }
      }
    }
  '';
}
