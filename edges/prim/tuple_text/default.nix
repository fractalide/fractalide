{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xe4d61f4e36da94a1;

    struct GenericTupleText {
      key @0 :Text;
      value @1 :Text;
    }
  '';
}
