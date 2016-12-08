{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xb547a1eef762172e;

    struct OptionPath {
        union {
            path @0 :Text;
            none @1 :Void;
        }
    }
  '';
}
