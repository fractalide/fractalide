{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xaf73df75f011fbb3;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct FsFileDesc {
        union {
          start @0 :PrimText.PrimText;
          text @1 :PrimText.PrimText;
          end @2 :PrimText.PrimText;
        }
    }
  '';
}
