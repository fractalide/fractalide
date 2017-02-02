{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ core_graph_ext ];
  schema = with edges; ''
    struct CoreGraphListExt {
      list @0 : List(CoreGraphExt);
    }
  '';
}
