{ buildFractalideContract}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xcd25af61b5d6c76b;

  struct GenericI64 {
          number @0 :Int64;
  }
  '';
}
