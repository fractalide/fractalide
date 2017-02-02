{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ntup_triple_ttt ];
  schema = with edges; ''
    struct NtupListTripleTtt {
      list @0 : List(NtupTripleTtt);
    }
  '';
}
