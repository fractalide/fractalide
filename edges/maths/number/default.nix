{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xbde554c96bf60f25;

    struct MathsNumber {
      number @0 :Int64;
    }
  '';
}
