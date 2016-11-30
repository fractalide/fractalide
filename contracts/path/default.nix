{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xad6ca52dabb3c4fd;

    struct Path {
            path @0 :Text;
    }
  '';
}
