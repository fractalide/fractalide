{ contract, contracts }:

contract rec {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xc5286a3290514068;

    struct FileList {
        files @0 :List(Text);
    }
  '';
}
