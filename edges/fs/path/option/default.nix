{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text prim_void ];
  schema = with edges; ''
    @0xa564e75d2890765e;

    using PrimText = import "${prim_text}/src/edge.capnp";
    using PrimVoid = import "${prim_void}/src/edge.capnp";

    struct FsPathOption {
        union {
            path @0 :PrimText.PrimText;
            none @1 :PrimVoid.PrimVoid;
        }
    }
  '';
}
