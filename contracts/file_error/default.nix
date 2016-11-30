{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0x9deaa106a95c1af8;

    struct FileError {
        notFound @0 :Text;
    }
  '';
}
