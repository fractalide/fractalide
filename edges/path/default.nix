{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xad6ca52dabb3c4fd;

    struct Path {
            path @0 :Text;
    }
  '';
}
