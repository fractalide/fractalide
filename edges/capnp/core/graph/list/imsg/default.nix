{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ CoreGraphImsg ];
  schema = with edges.capnp; ''
    struct CoreGraphListImsg {
      list @0 : List(CoreGraphImsg);
    }
  '';
}
