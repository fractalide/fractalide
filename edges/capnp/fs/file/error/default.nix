{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct FsFileError {
        notFound @0 :Text;
    }
  '';
}
