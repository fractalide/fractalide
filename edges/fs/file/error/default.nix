{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct FsFileError {
        notFound @0 :Text;
    }
  '';
}
