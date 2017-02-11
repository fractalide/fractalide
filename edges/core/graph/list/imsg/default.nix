{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ CoreGraphImsg ];
  schema = with edges; ''
    struct CoreGraphListImsg {
      list @0 : List(CoreGraphImsg);
    }
  '';
}
