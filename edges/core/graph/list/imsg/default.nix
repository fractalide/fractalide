{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ core_graph_imsg ];
  schema = with edges; ''
    struct CoreGraphListImsg {
      list @0 : List(CoreGraphImsg);
    }
  '';
}
