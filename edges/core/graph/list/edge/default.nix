{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ CoreGraphEdge ];
  schema = with edges; ''
    struct CoreGraphListEdge {
      list @0 : List(CoreGraphEdge);
    }
  '';
}
