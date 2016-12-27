{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0x9deaa106a95c1af8;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct FileError {
        notFound @0 :PrimText.PrimText;
    }
  '';
}
