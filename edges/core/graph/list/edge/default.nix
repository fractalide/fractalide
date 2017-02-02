{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ core_graph_edge ];
  schema = with edges; ''
    struct CoreGraphListEdge {
      list @0 : List(CoreGraphEdge);
    }
  '';
}
