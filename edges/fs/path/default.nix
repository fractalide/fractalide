{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct FsPath {
            path @0 :Text;
    }
  '';
}
