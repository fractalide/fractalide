{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ FsPath ];
  schema = with edges.capnp; ''
    struct FsListPath {
            list @0 :List(FsPath);
    }
  '';
}
