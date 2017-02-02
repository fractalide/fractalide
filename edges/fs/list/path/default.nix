{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ fs_path ];
  schema = with edges; ''
    struct FsListPath {
            list @0 :List(FsPath);
    }
  '';
}
