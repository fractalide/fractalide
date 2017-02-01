{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ core_graph_ext ];
  schema = with edges; ''
    @0xb1e7c78c125a612a;

    struct CoreGraphListExt {
      list @0 : List(CoreGraphExt);
    }
  '';
}
