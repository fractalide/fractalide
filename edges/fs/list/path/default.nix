{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ FsPath ];
  schema = with edges; ''
    struct FsListPath {
            list @0 :List(FsPath);
    }
  '';
}
