{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0xa564e75d2890765e;

    struct FsPathOption {
        union {
            path @0 :Text;
            none @1 :Void;
        }
    }
  '';
}
