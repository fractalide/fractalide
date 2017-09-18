{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ CoreGraphExt ];
  schema = with edges.capnp; ''
    struct CoreGraphListExt {
      list @0 : List(CoreGraphExt);
    }
  '';
}
