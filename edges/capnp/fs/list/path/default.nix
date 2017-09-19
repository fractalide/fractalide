{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ FsPath ];
  schema = with edges.capnp; ''
    struct FsListPath {
            list @0 :List(FsPath);
    }
  '';
}
