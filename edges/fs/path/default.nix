{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0x889b271db54c9019;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct FsPath {
            path @0 :PrimText.PrimText;
    }
  '';
}
