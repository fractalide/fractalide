{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0x889b271db54c9019;

    struct FsPath {
            path @0 :Text;
    }
  '';
}
