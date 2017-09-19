{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct FsPathOption {
        union {
            path @0 :Text;
            none @1 :Void;
        }
    }
  '';
}
