{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ core_graph_node ];
  schema = with edges; ''
    struct CoreGraphListNode {
      list @0 : List(CoreGraphNode);
    }
  '';
}
