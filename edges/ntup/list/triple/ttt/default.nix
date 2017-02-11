{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ NtupTripleTtt ];
  schema = with edges; ''
    struct NtupListTripleTtt {
      list @0 : List(NtupTripleTtt);
    }
  '';
}
