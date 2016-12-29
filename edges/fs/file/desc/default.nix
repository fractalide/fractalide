{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ prim_text ];
  schema = with edges; ''
    @0xaf73df75f011fbb3;

    struct FsFileDesc {
        union {
          start @0 :Text;
          text @1 :Text;
          end @2 :Text;
        }
    }
  '';
}
