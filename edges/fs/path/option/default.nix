{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct FsPathOption {
        union {
            path @0 :Text;
            none @1 :Void;
        }
    }
  '';
}
