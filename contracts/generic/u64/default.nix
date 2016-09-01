{ buildFractalideContract}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xcd25af61b5d6c76b;

  struct GenericU64 {
          number @0 :UInt64;
  }
  '';
}
