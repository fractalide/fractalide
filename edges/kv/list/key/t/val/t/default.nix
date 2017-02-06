{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ KvKeyTValT ];
  schema = with edges; ''
    struct KvListKeyTValT {
      list @0 : List(KvKeyTValT);
    }
  '';
}
