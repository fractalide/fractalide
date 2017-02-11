{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct FsFileDesc {
        union {
          start @0 :Text;
          text @1 :Text;
          end @2 :Text;
        }
    }
  '';
}
