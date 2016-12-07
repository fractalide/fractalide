{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xb1fc090ed4d12aee;

    struct GenericText {
            text @0 :Text;
    }
  '';
}
