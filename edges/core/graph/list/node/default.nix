{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ CoreGraphNode ];
  schema = with edges; ''
    struct CoreGraphListNode {
      list @0 : List(CoreGraphNode);
    }
  '';
}
