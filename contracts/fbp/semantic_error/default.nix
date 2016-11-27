{ contract, contracts }:

contract rec {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xf96c29a52799b766;

    struct FbpSemanticError {
      path @0 :Text;
      parsing @1 :List(Text);
    }
  '';
}
