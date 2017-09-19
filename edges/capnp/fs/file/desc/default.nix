{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct FsFileDesc {
        union {
          start @0 :Text;
          text @1 :Text;
          end @2 :Text;
        }
    }
  '';
}
