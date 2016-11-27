{ contract, contracts }:

contract rec {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0x9deaa106a95c1af8;

    struct FileError {
        notFound @0 :Text;
    }
  '';
}
