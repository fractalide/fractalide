{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ fs_path ];
  schema = with edges; ''
    @0xa207f15499102b31;

    using FsPath = import "${fs_path}/src/edge.capnp";

    struct FsListPath {
            list @0 :List(FsPath.FsPath);
    }
  '';
}
