{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ CoreGraphExt ];
  schema = with edges; ''
    struct CoreGraphListExt {
      list @0 : List(CoreGraphExt);
    }
  '';
}
